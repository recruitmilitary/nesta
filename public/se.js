function popWindow (el, options) {
  window.open(el.href, options.title, "width=" + options.width + ", height=" + options.height + ", scrollbars=yes, resizable=yes");
  return false;
}
