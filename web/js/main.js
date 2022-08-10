import { createOptions } from './createOptions.js';

window.addEventListener('message', (event) => {
  document.querySelectorAll('.option-container').forEach((option) => {
    option.remove();
  });
>>>>>>> test(web): horrible vanilla js

  switch (event.data.event) {
    case 'visible':
      document.body.style.visibility = event.data.state ? 'visible' : 'hidden';

    case 'setTarget':
      if (event.data.options) {
        for (const type in event.data.options) {
<<<<<<< refs/remotes/origin/main
          event.data.options[type].forEach((data, id) => {
            createOptions(type, data, id + 1);
          });
=======
          const options = event.data.options[type];

          for (const key in options) {
            options[key].forEach((data, target) => {
              createOptions(data, target + 1);
            });
          }
>>>>>>> test(web): horrible vanilla js
        }
      }
  }
});
