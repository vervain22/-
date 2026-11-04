import main,presentation_points
from native_fd_hub import NativeFDHub
from bounded_backend import NativeDisplay
main.FrameHub=NativeFDHub;main.render=presentation_points.render
backend=NativeDisplay();backend.install()
try:main.main()
finally:backend.uninstall()
