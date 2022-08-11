import { fetchNui } from './fetchNui.js';

function selectOption(type, id) {
  fetchNui('select', [type, id]);
  document.body.style.visibility = 'hidden';
}
const optionsWrapper = document.getElementById('options-wrapper');

export function createOptions(type, data, id) {
  if (data.hide) return;

  const option = document.createElement('div');
  option.className = 'option-container';
  option.innerHTML = `
      <i class="${data.icon} option-icon"></i>
      <p class="option-label">${data.label}</p>
    `;
  option.addEventListener('click', () => selectOption(type, id));
  optionsWrapper.appendChild(option);
}
