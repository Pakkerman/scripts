// one click download
// document.querySelectorAll('[icon-id=download]:not(.vi-button__icon__size)').forEach((item, idx)=> setTimeout(()=>{item.click()}, 500 * idx))

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log(`message ${message} received`)
  switch (message.action) {
    case 'run':
      run()
      break

    case 'generate':
      clickGenerate()
      break

    default:
      return
  }
})

function clickGenerate() {
  document.querySelectorAll('button').forEach((item) =>
    item.querySelectorAll('*').forEach((subitem) => {
      if (subitem?.textContent === '在线生成') subitem.click()
    })
  )
}

const upscalerFields = {
  高清修复采样次数: 15,
  重绘噪声强度: 0.3,
  采样次数: 1,
  '提示词相关性(CFG Scale)': 7,
  models: ['DPM++ SDE Karras', 'R-ESRGAN 4x+ Anime6B'],
}

const ADtailerFields = {
  重绘噪声强度: 0.4,
  采样次数: 10,
  '提示词相关性(CFG Scale)': 7,
  models: ['face_yolov8n_v2.pt', 'DPM++ SDE Karras'],
}

function run() {
  const pane = document.querySelectorAll('.n-tab-pane:not([class*=" "])')
  let selectedPane = ''
  pane.forEach((item) => {
    if (item.style.display != '') return
    selectedPane = item.querySelector('h3').textContent
  })

  toggleOpenMoreSettings()
  if (selectedPane === '高清修复') {
    fillfields(upscalerFields)
    selectModels(upscalerFields.models)
  } else if (selectedPane === 'ADetailer') {
    fillfields(ADtailerFields)
    selectModels(ADtailerFields.models)
  }
}

function selectModels(models) {
  const dropdowns = document.querySelectorAll('.n-select')
  click()
  setTimeout(click, 500)

  function click() {
    dropdowns.forEach((element) => {
      const clickable = element.querySelector('div')
      clickable.click()
    })
  }

  setTimeout(() => {
    const options = document.querySelectorAll('.n-base-select-option__content')
    options.forEach((option) => {
      if (models.includes(option.textContent)) option.click()
    })
  }, 1000)
}

function fillfields(fields) {
  const inputEvent = new Event('input', { bubbles: true })
  const labels = document.querySelectorAll('label')
  labels.forEach((element) => {
    const span = element.querySelector('span')
    if (!span) return

    const innerSpan = span.querySelector('span')
    const field = span.textContent ?? innerSpan.textContent
    if (field) {
      const value = fields[field]
      if (!field || value == null) return

      const input = element.parentElement.querySelector('input')

      input.value = String(value)
      input.dispatchEvent(inputEvent)
    }
  })
}

function toggleOpenMoreSettings() {
  const toggle = document.querySelectorAll('[icon-id="arrowup"]')
  toggle.forEach((item) => {
    if (!item.classList.contains('rotate-180')) item.click()
  })
}
