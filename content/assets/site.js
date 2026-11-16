function copyInstall(button) {
  var code = button.parentElement.querySelector("code");
  var done = function () {
    var old = button.textContent;
    button.textContent = "Copied!";
    setTimeout(function () {
      button.textContent = old;
    }, 1200);
  };
  if (navigator.clipboard) {
    navigator.clipboard.writeText(code.innerText).then(done);
  } else {
    var area = document.createElement("textarea");
    area.value = code.innerText;
    document.body.appendChild(area);
    area.select();
    document.execCommand("copy");
    document.body.removeChild(area);
    done();
  }
}
