import { fetchNui } from './fetchNui.js';

const optionsWrapper = document.getElementById('options-wrapper');

export function createOptions(type, data, id) {
  if (data.hide) return;

  const option = document.createElement('div');
  option.className = 'option-container';
  option.innerHTML = `
      <i class="${data.icon} option-icon"></i>
      <p class="option-label">${data.label}</p>
    `;
  option.addEventListener('click', () => fetchNui('select', [type, id]));
  optionsWrapper.appendChild(option);
}
