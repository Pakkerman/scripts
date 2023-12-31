console.log('background loaded')

chrome.action.onClicked.addListener((tab) => {
  console.log(tab)
  console.log('msg send')
  chrome.tabs.sendMessage(tab.id, { action: 'run' })
})

chrome.commands.onCommand.addListener((command) => {
  console.log(`call ${command} command`)

  chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
    chrome.tabs.sendMessage(tabs[0].id, { action: command })
  })
})
