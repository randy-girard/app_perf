class Utils {
  static updateQueryStringParameter (uri, key, value) {
    var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
    var separator = uri.indexOf('?') !== -1 ? "&" : "?";
    if (uri.match(re)) {
      if(value == "")
        return uri.replace(re, '$1');
      else {
        return uri.replace(re, '$1' + key + "=" + value + '$2');
      }
    }
    else {
      return uri + separator + key + "=" + value;
    }
  }
}
export default Utils
