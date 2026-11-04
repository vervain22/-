/* Separate misc device: opening/closing it NEVER stops the capture stream. */
#include <linux/miscdevice.h>
#include <linux/mutex.h>
#include <linux/io.h>

struct roi_cfg { __u32 version, enable; __u32 boxes[4][4]; };
struct roi_result { __u32 seq, frame, version, enable; __u32 counts[5][4]; };
#define ROI_GET_ID _IOR('R', 0, __u32)
#define ROI_CONFIG _IOW('R', 1, struct roi_cfg)
#define ROI_SNAPSHOT _IOR('R', 2, struct roi_result)
struct roi_diag { __u32 seq, status, words[16]; };
#define ROI_DIAGNOSTICS _IOR('R', 3, struct roi_diag)
struct roi_diag_ext { __u32 seq, status, pixels, min_width, max_width, error; };
#define ROI_DIAGNOSTICS_EXT _IOR('R', 4, struct roi_diag_ext)
#define ROI_MAGIC 0x524f4931u
static void __iomem *roi_base;
static DEFINE_MUTEX(roi_mutex);
static bool roi_registered;

static long roi_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
    struct roi_cfg cfg;
    struct roi_result out;
    struct roi_diag diag;
    struct roi_diag_ext ext;
    __u32 id, before;
    int i,j,ret=0;
    if (mutex_lock_interruptible(&roi_mutex)) return -ERESTARTSYS;
    if (!roi_base) { ret=-ENODEV; goto done; }
    id=ioread32(roi_base);
    if (id!=ROI_MAGIC) { ret=-ENODEV; goto done; }
    switch(cmd) {
    case ROI_GET_ID:
        if (copy_to_user((void __user *)arg,&id,sizeof(id))) ret=-EFAULT;
        break;
    case ROI_CONFIG:
        if (copy_from_user(&cfg,(void __user *)arg,sizeof(cfg))) { ret=-EFAULT; break; }
        if (!cfg.version || cfg.enable>15) { ret=-EINVAL; break; }
        for (i=0;i<4;i++) {
            if (cfg.boxes[i][0]>1920 || cfg.boxes[i][2]>1920 ||
                cfg.boxes[i][1]>1080 || cfg.boxes[i][3]>1080 ||
                ((cfg.enable & (1u<<i)) &&
                 (cfg.boxes[i][0]>=cfg.boxes[i][2] || cfg.boxes[i][1]>=cfg.boxes[i][3]))) {
                ret=-EINVAL; goto done;
            }
        }
        if (!(ioread32(roi_base+4)&1)) { ret=-EAGAIN; break; }
        /* Full DWORD writes. All shadow coordinates precede the commit. */
        for (i=0;i<4;i++) for (j=0;j<4;j++)
            iowrite32(cfg.boxes[i][j],roi_base+0x20+i*16+j*4);
        iowrite32(cfg.enable,roi_base+0x14);
        iowrite32(1,roi_base+0x1c); /* clear previous rejected-commit flag */
        iowrite32(cfg.version,roi_base+0x10);
        if (ioread32(roi_base+4)&4) ret=-EAGAIN; /* flush posted writes */
        break;
    case ROI_DIAGNOSTICS_EXT:
        if (ioread32(roi_base+0x30)!=0x44584731u) { ret=-EOPNOTSUPP; break; }
        before=ioread32(roi_base+8);
        iowrite32(1,roi_base+0x18);
        ext.seq=ioread32(roi_base+0x80);
        if (ext.seq!=before+1) { ret=-EIO; break; }
        ext.status=ioread32(roi_base+4);
        ext.pixels=ioread32(roi_base+0x20);
        ext.min_width=ioread32(roi_base+0x24);
        ext.max_width=ioread32(roi_base+0x28);
        ext.error=ioread32(roi_base+0x2c);
        if (copy_to_user((void __user *)arg,&ext,sizeof(ext))) ret=-EFAULT;
        break;
    case ROI_DIAGNOSTICS:
        before=ioread32(roi_base+8);
        iowrite32(1,roi_base+0x18);
        diag.seq=ioread32(roi_base+0x80);
        if (diag.seq!=before+1) { ret=-EIO; break; }
        diag.status=ioread32(roi_base+4);
        for (i=0;i<16;i++) {
            /* words 6,7,e,f; all frozen by the same snapshot request. */
            j=(i<8) ? 0x60+i*4 : 0xe0+(i-8)*4;
            diag.words[i]=ioread32(roi_base+j);
        }
        if (diag.words[15]!=0x44424731u) { ret=-EOPNOTSUPP; break; }
        if (copy_to_user((void __user *)arg,&diag,sizeof(diag))) ret=-EFAULT;
        break;
    case ROI_SNAPSHOT:
        before=ioread32(roi_base+8);
        iowrite32(1,roi_base+0x18);
        out.seq=ioread32(roi_base+0x80);
        if (out.seq!=before+1) { ret=-EIO; break; }
        out.frame=ioread32(roi_base+0x84);
        out.version=ioread32(roi_base+0x88);
        out.enable=ioread32(roi_base+0x8c);
        for (i=0;i<5;i++) for (j=0;j<4;j++)
            out.counts[i][j]=ioread32(roi_base+0x90+i*16+j*4);
        if (copy_to_user((void __user *)arg,&out,sizeof(out))) ret=-EFAULT;
        break;
    default: ret=-ENOTTY;
    }
done:
    mutex_unlock(&roi_mutex);
    return ret;
}
static const struct file_operations roi_fops = {
    .owner=THIS_MODULE,.unlocked_ioctl=roi_ioctl,.llseek=no_llseek,
};
static struct miscdevice roi_misc = {
    .minor=MISC_DYNAMIC_MINOR,.name="pango_roi",.fops=&roi_fops,.mode=0600,
};
static void roi_aux_start(struct pci_dev *dev)
{
    int ret;
    if (!(pci_resource_flags(dev,0)&IORESOURCE_MEM) || pci_resource_len(dev,0)<0x900) return;
    ret=pci_request_region(dev,0,"pango_roi");
    if (ret) { dev_warn(&dev->dev,"ROI BAR0 unavailable: %d\n",ret); return; }
    roi_base=pci_iomap_range(dev,0,0x800,0x100);
    if (!roi_base || ioread32(roi_base)!=ROI_MAGIC) {
        if (roi_base) pci_iounmap(dev,roi_base);
        roi_base=NULL;pci_release_region(dev,0);
        dev_info(&dev->dev,"ROI auxiliary bitstream not present; capture unchanged\n");return;
    }
    ret=misc_register(&roi_misc);
    if (ret) { pci_iounmap(dev,roi_base);roi_base=NULL;pci_release_region(dev,0);return; }
    roi_registered=true;
}
static void roi_aux_stop(struct pci_dev *dev)
{
    if (!roi_registered) return;
    misc_deregister(&roi_misc);
    mutex_lock(&roi_mutex);
    pci_iounmap(dev,roi_base);roi_base=NULL;
    mutex_unlock(&roi_mutex);
    pci_release_region(dev,0);roi_registered=false;
}
