import platform

from igibson.render.mesh_renderer.get_available_devices import get_available_devices
from igibson.render.mesh_renderer.mesh_renderer_settings import MeshRendererSettings

import pytest

@pytest.mark.skipif(platform.system() == "Windows", reason="Only works on Unix-like systems")
def test_device():
    assert len(get_available_devices()[0]) > 0


def test_binding():
    if platform.system() == "Darwin" or platform.system() == "Windows":
        from igibson.render.mesh_renderer import GLFWRendererContext

        setting = MeshRendererSettings()
        r = GLFWRendererContext.GLFWRendererContext(
            256, 256, setting.glfw_gl_version[0], setting.glfw_gl_version[1], False, False
        )
    else:
        from igibson.render.mesh_renderer import EGLRendererContext

        r = EGLRendererContext.EGLRendererContext(256, 256, get_available_devices()[0][0])
    r.init()
    r.release()
