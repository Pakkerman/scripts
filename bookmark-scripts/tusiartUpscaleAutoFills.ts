// use this when using in bookmark
// javascript:(function(){...})()

function autoFill() {
  // select upscale model
  document
    .querySelectorAll('.n-base-select-option__content')
    .forEach((item) => {
      if (item.textContent === 'R-ESRGAN 4x+ Anime6B') {
        item.click()
      }
    })
}

// // Create a new input event
//     const inputEvent = new Event('input', { bubbles: true });

//     // Convert the numeric value to a string and set it as the input value
//     inputElement.value = String(numericValue);

//     // Dispatch the input event on the input element
//     inputElement.dispatchEvent(inputEvent);
// }
