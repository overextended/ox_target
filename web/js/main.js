import { createOptions } from './createOptions.js';

const optionsWrapper = document.getElementById('options-wrapper');
const body = document.body;
const eye = document.getElementById('eyeSvg');
const defaultIcon = 'fa-solid fa-eye';
let currentIcon;

const setMainIcon = function (newIcon = defaultIcon) {
  if (!currentIcon || newIcon !== currentIcon) {
    if (currentIcon) {
      const previousIconData = currentIcon.split(' ');

      for (let i = 0; i < previousIconData.length; i++) {
        eye.classList.remove(previousIconData[i]);
      }
    }
    
    const newIconData = newIcon.split(' ');

    for (let i = 0; i < newIconData.length; i++) {
      eye.classList.add(newIconData[i]);
    }

    currentIcon = newIcon;
  }
};

const setMainIconColor = function (newIconColor) {
  eye.style.color = newIconColor
};

window.addEventListener('message', (event) => {
  optionsWrapper.innerHTML = '';

  setMainIcon(defaultIcon);
  
  switch (event.data.event) {
    case 'visible': {
      body.style.visibility = event.data.state ? 'visible' : 'hidden';
      return setMainIconColor('black');
    }

    case 'leftTarget': {
      return setMainIconColor('black');
    }

    case 'setTarget': {
      setMainIcon(event.data.icon);
      setMainIconColor(event.data.mainIconColor || '#cfd2da');

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
