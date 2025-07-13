from .base_engine import BaseEngine, TimingInfo

__all__ = [
    "BaseEngine", "TimingInfo",
    "CoquiEngine", "CoquiVoice",

]


# Lazy loader functions for the engines in this subpackage.



def _load_system_engine():
    from .system_engine import SystemEngine, SystemVoice
    globals()["SystemEngine"] = SystemEngine
    globals()["SystemVoice"] = SystemVoice
    return SystemEngine




def _load_coqui_engine():
    from .coqui_engine import CoquiEngine, CoquiVoice
    globals()["CoquiEngine"] = CoquiEngine
    globals()["CoquiVoice"] = CoquiVoice
    return CoquiEngine


# Map attribute names to lazy loader functions.
_lazy_imports = {
    "SystemEngine": _load_system_engine,
    "SystemVoice": _load_system_engine,
    "CoquiEngine": _load_coqui_engine,
    "CoquiVoice": _load_coqui_engine,
}


def __getattr__(name):
    if name in _lazy_imports:
        return _lazy_imports[name]()
    raise AttributeError(f"module {__name__} has no attribute {name}")
