class ItemSelectedListener {
  bool _isSelected = false;
  bool _isEnable = true;
  Function _rebuildFn;

  bool get isSelected => _isSelected;

  bool get isEnable => _isEnable;

  void notifyUnselect() {
    _isSelected = false;
    if (_rebuildFn != null) _rebuildFn();
  }

  void notifySelect({bool forceRebuild = false}) {
    _isSelected = true;
    if (forceRebuild && _rebuildFn != null) _rebuildFn();
  }

  void notifyEnable({bool forceRebuild = false}) {
    _isEnable = true;
    if (forceRebuild && _rebuildFn != null) _rebuildFn();
  }

  void notifyDisable({bool forceRebuild = false}) {
    _isEnable = false;
    if (forceRebuild && _rebuildFn != null) _rebuildFn();
  }

  void setListener(final Function func) {
    this._rebuildFn = func;
  }

  void rebuild() {
    if (_rebuildFn != null) _rebuildFn();
  }
}
