import { createOptions } from './createOptions.js';

const optionsWrapper = document.getElementById('options-wrapper');
const body = document.body;
const eye = document.getElementById('eyeSvg');
const defaultIcon = "fa-solid fa-eye";
let currentIcon;

const addEyeIcon = function (newIcon = defaultIcon) {
  if (!currentIcon || newIcon !== currentIcon) {
    if (currentIcon) {
      const previousIconData = currentIcon.split(" ");

      for (let i = 0; i < previousIconData.length; i++) {
        eye.classList.remove(previousIconData[i]);
      }
    }
    
    const newIconData = newIcon.split(" ");

    for (let i = 0; i < newIconData.length; i++) {
      eye.classList.add(newIconData[i]);
    }

    currentIcon = newIcon;
  }
};

window.addEventListener('message', (event) => {
  optionsWrapper.innerHTML = '';

  addEyeIcon(defaultIcon);
  
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
        addEyeIcon(event.data.icon);
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
