function getRPCErrorMessage(err) {
  var open = err.stack.indexOf('{');
  var close = err.stack.lastIndexOf('}');
  var j_s = err.stack.substring(open, close + 1);
  var jsonErrorMessage = JSON.parse(j_s);
  return jsonErrorMessage;
}

export { getRPCErrorMessage };
