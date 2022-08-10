import { fetchNui } from "./fetchNui.js";

function selectOption(type, id) {
  fetchNui("select", [type, id]);
  document.body.style.visibility = "hidden";
}

export function createOptions(type, data, id) {
  const child = document.createElement("p");
  child.className = "child";
  child.innerHTML = `<i class="${
    data.icon || "fa-solid fa-circle-info"
  }"></i> ${data.label}`;

  child.addEventListener("click", () => selectOption(type, id));
  document.getElementById("menu").appendChild(child);
}
