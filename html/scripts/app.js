(function () {
  let status = [];

  let renderStatus = function () {
    document.getElementById("status_list").innerHTML = "";

    for (let i = 0; i < status.length; i++) {
      if (!status[i].visible) {
        continue;
      }

      const statusVal = document.createElement("div");
      statusVal.style.width = status[i].percent + "%";
      statusVal.style.backgroundColor = status[i].color;
      statusVal.classList.add("status_val");

      const statusInner = document.createElement("div");
      statusInner.classList.add("status_inner");
      statusInner.style.border = "1px solid " + status[i].color;
      statusInner.appendChild(statusVal);

      const statusDiv = document.createElement("div");
      statusDiv.classList.add("status");
      statusDiv.appendChild(statusInner);

      document.getElementById("status_list").appendChild(statusDiv);
    }
  };

  window.onData = function (data) {
    if (data.update) {
      status.length = 0;

      for (let i = 0; i < data.status.length; i++) {
        status.push(data.status[i]);
      }

      renderStatus();
    }

    if (data.setDisplay) {
      document.getElementById("status_list").style.opacity = data.display;
    }
  };

  window.onload = function () {
    window.addEventListener("message", function (event) {
      onData(event.data);
    });
  };
})();
