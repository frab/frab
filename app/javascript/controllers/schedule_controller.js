import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="schedule"
export default class extends Controller {

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
  }
  static targets = ["trackSelect", "eventTypeSelect", "unscheduledEvents", "eventPane", "addEventModal", "currentTime"]

  connect() {
    console.log("Schedule controller connected")
    console.log("Found", document.querySelectorAll('div.event').length, "scheduled events")
    console.log("Found", document.querySelectorAll('li.unscheduled-event').length, "unscheduled events")
    console.log("Found", document.querySelectorAll('table.room td').length, "time slots")

    this.setupEventListeners()
    this.initializeDragAndDrop()
    this.positionExistingEvents()
  }

  setupEventListeners() {
    // Track and event type filter changes
    if (this.hasTrackSelectTarget) {
      this.trackSelectTarget.addEventListener('change', this.updateUnscheduledEvents.bind(this))
    }

    if (this.hasEventTypeSelectTarget) {
      this.eventTypeSelectTarget.addEventListener('change', this.updateUnscheduledEvents.bind(this))
    }

    // Use event delegation for elements that might be added dynamically
    this.element.addEventListener('mouseenter', this.handleEventMouseEnter.bind(this), true)
    this.element.addEventListener('mouseleave', this.handleEventMouseLeave.bind(this), true)
    this.element.addEventListener('click', this.handleEventClick.bind(this), true)

    // Room toggle buttons - use event delegation
    this.element.addEventListener('click', (e) => {
      if (e.target.classList.contains('toggle-room')) {
        this.handleRoomToggle(e)
      }
      if (e.target.id === 'hide-all-rooms') {
        this.hideAllRooms(e)
      }
      if (e.target.id === 'select_all_rooms') {
        this.handleSelectAllRooms(e)
      }
      // Time slot clicks - check if clicked element is a td in table.room
      if (e.target.tagName === 'TD' && e.target.closest('table.room')) {
        this.handleTimeslotClick(e)
      }
    })
  }

  updateUnscheduledEvents() {
    const form = document.querySelector('form#update-filters')
    if (!form) return

    const trackId = this.hasTrackSelectTarget ? this.trackSelectTarget.value : ''
    const eventType = this.hasEventTypeSelectTarget ? this.eventTypeSelectTarget.value : ''

    const formData = new FormData()
    formData.append('track_id', trackId)
    formData.append('event_type', eventType)

    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken()
      }
    })
    .then(response => response.text())
    .then(html => {
      if (this.hasUnscheduledEventsTarget) {
        this.unscheduledEventsTarget.innerHTML = html
        // Make newly loaded unscheduled events draggable
        this.unscheduledEventsTarget.querySelectorAll('li.unscheduled-event').forEach(event => {
          this.makeDraggable(event)
        })
      }
    })
    .catch(error => console.error('Error updating unscheduled events:', error))
  }

  handleEventMouseEnter(event) {
    if (!event.target.classList.contains('event')) return

    const eventDiv = event.target
    if (eventDiv.querySelector('a.close')) return

    // Add show button
    const showButton = document.createElement('a')
    showButton.href = eventDiv.dataset.showEventUrl
    showButton.target = '_blank'
    showButton.innerHTML = '<img src="/assets/external_link.svg" style="height:0.8rem;">'
    showButton.className = 'close small'
    showButton.addEventListener('click', (e) => {
      e.stopPropagation()
      window.open(eventDiv.dataset.showEventUrl)
    })
    eventDiv.prepend(showButton)

    // Add unschedule button
    const unschedule = document.createElement('a')
    unschedule.href = '#'
    unschedule.textContent = '×'
    unschedule.className = 'close small'
    unschedule.addEventListener('click', (e) => {
      this.unscheduleEvent(eventDiv, e)
    })
    eventDiv.prepend(unschedule)
  }

  handleEventMouseLeave(event) {
    if (!event.target.classList.contains('event')) return

    event.target.querySelectorAll('a.close').forEach(button => button.remove())
  }

  handleEventClick(event) {
    if (!event.target.classList.contains('event')) return

    event.stopPropagation()
    event.preventDefault()
    return false
  }

  unscheduleEvent(eventDiv, clickEvent) {
    const updateUrl = eventDiv.dataset.updateUrl
    if (!updateUrl) return

    const formData = new FormData()
    formData.append('event[start_time]', '')
    formData.append('event[room_id]', '')

    fetch(updateUrl, {
      method: 'PUT',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken()
      }
    })
    .then(response => {
      if (response.ok) {
        eventDiv.remove()
        this.updateUnscheduledEvents()
      }
    })
    .catch(error => console.error('Error unscheduling event:', error))

    clickEvent.stopPropagation()
    clickEvent.preventDefault()
    return false
  }

  handleRoomToggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const roomName = button.dataset.room
    const roomTable = document.querySelector(`table[data-room='${roomName}']`)

    if (roomTable) {
      roomTable.style.display = roomTable.style.display === 'none' ? '' : 'none'

      if (button.classList.contains('success')) {
        button.classList.remove('success')
      } else {
        button.classList.add('success')
      }

      // Update event positions
      document.querySelectorAll('table.room div.event').forEach(event => {
        this.updateEventPosition(event)
      })
    }

    return false
  }

  hideAllRooms(event) {
    event.preventDefault()
    document.querySelectorAll('a.toggle-room').forEach(button => {
      button.classList.remove('success')
    })
    document.querySelectorAll('table.room').forEach(table => {
      table.style.display = 'none'
    })
    return false
  }

  handleTimeslotClick(event) {
    console.log("Time slot clicked:", event.target, "Data-time:", event.target.dataset.time)
    event.preventDefault()
    event.stopPropagation()

    const td = event.target
    if (this.hasCurrentTimeTarget) {
      this.currentTimeTarget.innerHTML = td.dataset.time || "Unknown time"
    }

    // Setup add event listeners
    this.setupAddEventListeners(td)

    // Make sure unscheduled events in modal are draggable
    if (this.hasUnscheduledEventsTarget) {
      this.unscheduledEventsTarget.querySelectorAll('li.unscheduled-event').forEach(event => {
        this.makeDraggable(event)
      })
    }

    // Show modal
    if (this.hasAddEventModalTarget) {
      console.log("Opening modal...")
      const modal = new bootstrap.Modal(this.addEventModalTarget)
      modal.show()
    } else {
      console.log("No modal target found!")
    }

    return false
  }

  setupAddEventListeners(targetTd) {
    // Remove existing listeners
    if (this.hasUnscheduledEventsTarget) {
      const oldListeners = this.unscheduledEventsTarget.querySelectorAll('li span#add a')
      oldListeners.forEach(link => {
        link.replaceWith(link.cloneNode(true)) // Remove all event listeners
      })

      // Add new listeners
      this.unscheduledEventsTarget.querySelectorAll('li span#add a').forEach(link => {
        link.addEventListener('click', (e) => {
          this.addEventToSlot(e, targetTd)
        })
      })
    }
  }

  addEventToSlot(clickEvent, td) {
    clickEvent.preventDefault()

    const li = clickEvent.target.closest('li')
    if (!li) return

    // Create new event div
    const newEvent = document.createElement('div')
    newEvent.innerHTML = li.querySelector('span').innerHTML
    newEvent.className = 'event'
    newEvent.id = li.id
    newEvent.style.height = li.dataset.height
    newEvent.dataset.updateUrl = li.dataset.updateUrl
    newEvent.dataset.showEventUrl = li.dataset.showEventUrl

    // Add to event pane and slot
    if (this.hasEventPaneTarget) {
      this.eventPaneTarget.appendChild(newEvent)
    }

    this.addEventToTimeSlot(newEvent, td, true)
    this.makeDraggable(newEvent)

    // Remove from unscheduled list
    li.remove()

    // Hide modal
    if (this.hasAddEventModalTarget) {
      const modal = bootstrap.Modal.getInstance(this.addEventModalTarget)
      if (modal) modal.hide()
    }

    return false
  }

  addEventToTimeSlot(eventElement, td, update = true) {
    const event = eventElement
    event.dataset.slot = td
    td.appendChild(event)
    this.updateEventPosition(event)

    if (update) {
      event.dataset.time = td.dataset.time
      event.dataset.room = td.dataset.room

      const formData = new FormData()
      formData.append('event[start_time]', td.dataset.time)
      formData.append('event[room_id]', td.closest('table.room').dataset.roomId)

      fetch(event.dataset.updateUrl, {
        method: 'PUT',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })
      .then(response => {
        if (response.ok) {
          // Highlight effect
          event.style.backgroundColor = '#ffff99'
          setTimeout(() => {
            event.style.backgroundColor = ''
          }, 1000)
        }
      })
      .catch(error => console.error('Error updating event:', error))
    }
  }

  updateEventPosition(eventElement) {
    const event = eventElement
    const td = event.closest('td')
    if (!td) return

    // Position relatively within the parent td instead of absolutely
    td.style.position = 'relative'
    event.style.position = 'relative'
    event.style.left = '0'
    event.style.top = '0'
    event.style.width = '100%'
  }

  initializeDragAndDrop() {
    // Make existing events draggable within this controller's scope
    this.element.querySelectorAll('div.event').forEach(event => {
      this.makeDraggable(event)
    })

    // Make unscheduled events draggable
    this.element.querySelectorAll('li.unscheduled-event').forEach(event => {
      this.makeDraggable(event)
    })

    // Make time slots droppable
    this.element.querySelectorAll('table.room td').forEach(td => {
      this.makeDroppable(td)
    })
  }

  makeDraggable(element) {
    element.draggable = true
    element.style.cursor = 'move'

    element.addEventListener('dragstart', (e) => {
      element.style.opacity = '0.4'
      e.dataTransfer.effectAllowed = 'move'
      e.dataTransfer.setData('text/html', element.outerHTML)
      e.dataTransfer.setData('text/plain', element.id)
      this.draggedElement = element
    })

    element.addEventListener('dragend', (e) => {
      element.style.opacity = '1'
      this.draggedElement = null
    })
  }

  makeDroppable(td) {
    td.addEventListener('dragover', (e) => {
      e.preventDefault()
      e.dataTransfer.dropEffect = 'move'
      td.classList.add('event-hover')
    })

    td.addEventListener('dragleave', (e) => {
      // Only remove hover if we're actually leaving this element
      if (!td.contains(e.relatedTarget)) {
        td.classList.remove('event-hover')
      }
    })

    td.addEventListener('drop', (e) => {
      e.preventDefault()
      td.classList.remove('event-hover')

      if (this.draggedElement) {
        if (this.draggedElement.classList.contains('unscheduled-event')) {
          // Handle unscheduled event (li element)
          this.scheduleUnscheduledEvent(this.draggedElement, td)
        } else {
          // Handle already scheduled event (div element)
          this.addEventToTimeSlot(this.draggedElement, td, true)
        }
      }
    })
  }

  scheduleUnscheduledEvent(li, td) {
    // Create new event div from the unscheduled event li
    const newEvent = document.createElement('div')
    newEvent.className = 'event'
    newEvent.id = li.id
    newEvent.style.height = li.dataset.height + 'px'
    newEvent.dataset.updateUrl = li.dataset.updateUrl
    newEvent.dataset.showEventUrl = li.dataset.showEventUrl

    // Get the event title from the link
    const titleLink = li.querySelector('span#add a')
    if (titleLink) {
      newEvent.innerHTML = `<span>${titleLink.textContent}</span>`
    }

    // Add to event pane and schedule it
    if (this.hasEventPaneTarget) {
      this.eventPaneTarget.appendChild(newEvent)
    }

    this.addEventToTimeSlot(newEvent, td, true)
    this.makeDraggable(newEvent)

    // Remove from unscheduled list
    li.remove()

    // Close modal if open
    if (this.hasAddEventModalTarget) {
      const modal = bootstrap.Modal.getInstance(this.addEventModalTarget)
      if (modal) modal.hide()
    }
  }

  positionExistingEvents() {
    this.element.querySelectorAll('div.event').forEach(event => {
      if (event.dataset.room && event.dataset.time) {
        const roomTable = this.element.querySelector(`table[data-room='${event.dataset.room}']`)
        const startingCell = roomTable?.querySelector(`td[data-time='${event.dataset.time}']`)

        if (startingCell) {
          this.addEventToTimeSlot(event, startingCell, false)
        }
      }
    })
  }

  handleSelectAllRooms(event) {
    const checked = event.target.checked
    document.querySelectorAll('input[name^="room_ids"]').forEach(input => {
      input.checked = checked
    })
  }
}
