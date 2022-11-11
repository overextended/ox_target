import { createOptions } from './createOptions.js';

const optionsWrapper = document.getElementById('options-wrapper');
const body = document.body;
const eye = document.getElementById('eyeSvg');

window.addEventListener('message', (event) => {
  optionsWrapper.innerHTML = '';

  switch (event.data.event) {
    case 'visible': {
      body.style.visibility = event.data.state ? 'visible' : 'hidden';
      return (eye.style.fill = 'white');
    }

    case 'leftTarget': {
      return (eye.style.fill = 'white');
    }

    case 'setTarget': {
      eye.style.fill = '#00f8b9';

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
