import { fetchNui } from './fetchNui.js';

<<<<<<< refs/remotes/origin/main
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
=======
function selectOption(target, id) {
  fetchNui('select', { target: target, option: id });
  document.body.style.visibility = 'hidden';
}

const optionsWrapper = document.getElementById('options-wrapper');

export function createOptions(data, target) {
  if (data) {
    // option.innerHTML = `<i class="${
    //   data.icon || "fa-solid fa-circle-info"
    // }"></i> ${data.label}`;
    const option = document.createElement('div');
    option.className = 'option-container';
    option.innerHTML = `
      <i class="${data.icon} option-icon"></i>
      <p class="option-label">${data.label}</p>
    `;
    option.addEventListener('click', () => {
      selectOption(target, id + 1);
    });
    optionsWrapper.appendChild(option);
  }
>>>>>>> test(web): horrible vanilla js
}
