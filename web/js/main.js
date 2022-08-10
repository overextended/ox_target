import { createOptions } from './createOptions.js';

window.addEventListener('message', (event) => {
  document.getElementById('options-wrapper').innerHTML = '';

  switch (event.data.event) {
    case 'visible':
      document.body.style.visibility = event.data.state ? 'visible' : 'hidden';

    case 'setTarget':
      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            createOptions(type, data, id + 1);
          });
        }
      }
  }
});
