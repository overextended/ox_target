import { createOptions } from './createOptions.js';

const optionsWrapper = document.getElementById('options-wrapper');
const body = document.body;
const eye = document.getElementById('eyeSvg');
const defaultIcon = "fa-solid fa-eye";
let currentIcon;

window.addEventListener('message', (event) => {
  optionsWrapper.innerHTML = '';

  if (!currentIcon || currentIcon !== defaultIcon) {
    if (currentIcon) {
      eye.classList.remove(currentIcon);
    }

    eye.classList.add(defaultIcon);
    currentIcon = defaultIcon;
  }
  
  switch (event.data.event) {
    case 'visible': {
      body.style.visibility = event.data.state ? 'visible' : 'hidden';
      return (eye.style.color = 'black');
    }

    case 'leftTarget': {
      return (eye.style.color = 'black');
    }

    case 'setTarget': {
      if (event.data.icon) {
        eye.classList.add(event.data.icon);
        currentIcon = event.data.icon;
      }

      eye.style.color = '#cfd2da';

      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            createOptions(type, data, id + 1);
          });
        }
      }
    }
  }
});
