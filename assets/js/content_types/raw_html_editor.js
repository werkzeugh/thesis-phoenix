import React from 'react'
import RawHtmlTray from './raw_html_tray'

class RawHtmlEditor {
  constructor (opts) {
    this.editors = document.querySelectorAll('.thesis-content-raw_html')
    this.enabled = false

    this.openTray = opts.openTray
    this.closeTray = opts.closeTray

    this.clicked = this.clicked.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  enable () {
    if (this.enabled) return
    for (let i = 0; i < this.editors.length; i++) {
      this.editors[i].addEventListener('click', this.clicked, false)
    }
    this.enabled = true
  }

  disable () {
    if (!this.enabled) return
    for (let i = 0; i < this.editors.length; i++) {
      this.editors[i].removeEventListener('click', this.clicked, false)
    }
    this.enabled = false
  }

  content (ed) {
    return ed.innerHTML
  }

  set (name, data) {
    const ed = document.querySelector(`[data-thesis-content-id='${name}']`)
    if (!ed) return
    ed.innerHTML = data.content
    ed.classList.add('modified')
  }

  clicked (e) {
    const id = e.currentTarget.getAttribute('data-thesis-content-id')
    const content = e.currentTarget.innerHTML.trim()

    this.openTray({ contentId: id, content: content })
  }

  onSubmit (data) {
    this.set(data.contentId, data)
    this.closeTray()
  }

  tray (data) {
    return <RawHtmlTray
      data={data}
      onCancel={this.closeTray}
      onSubmit={this.onSubmit} />
  }

}

export default RawHtmlEditor
