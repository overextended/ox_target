import { createOptions } from './createOptions.js';

const optionsWrapper = $('#options-wrapper');

const setFindingState = (state) => {
    $('body').stop().fadeTo(250, state ? 1 : 0);
}

const setPointState = (state) => {
    $('#point').stop().fadeTo(250, state ? 1 : 0);
    $("#finding").stop().fadeTo(250, state ? 0 : 1);
}

$(window).on('message', (event) => {
    optionsWrapper.empty();

    switch (event.originalEvent.data.event) {
        case 'visible': {
            setFindingState(event.originalEvent.data.state)
            setPointState(false);
            break;
        }

        case 'leftTarget': {
            setPointState(false);

            break;
        }

        case 'setTarget': {
            setPointState(true);

            if (event.originalEvent.data.options) {
                for (const type in event.originalEvent.data.options) {
                    event.originalEvent.data.options[type].forEach((data, id) => {
                        createOptions(type, data, id + 1);
                    });
                }
            }
            break;
        }
    }
});