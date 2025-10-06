import { Controller } from "@hotwired/stimulus"

/**
 * Schedule Controller - Manages conference event scheduling interface
 *
 * This controller handles:
 * - Drag-and-drop scheduling of events into time slots
 * - Filtering unscheduled events by track and type
 * - Adding/removing events from schedule via modal or drag-and-drop
 * - Dynamic event card reloading after schedule changes
 * - Room visibility toggling
 *
 * Key concepts:
 * - Scheduled events are <div class="event"> in time slot <td> cells
 * - Unscheduled events are <li class="unscheduled-event"> in a sidebar/modal list
 * - Events can be scheduled by: clicking time slot (opens modal), dragging from modal, or dragging between slots
 * - All schedule updates use fetch() with PUT to update_event endpoint
 * - Filter updates use fetch() with GET to update_filters endpoint (not POST!)
 */
export default class extends Controller {

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
  }
  static targets = ["trackSelect", "eventTypeSelect", "unscheduledEvents", "eventPane", "addEventModal", "currentTime"]

  connect() {
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
      // Check for close button clicks first (highest priority)
      if (e.target.closest('a.close')) {
        return // Let the close button handler deal with it
      }
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

  /**
   * Fetches and updates the unscheduled events list based on current filter selections
   * Important: Uses GET not POST - the route only accepts GET requests
   * After updating, re-initializes drag-and-drop and click handlers for new elements
   */
  updateUnscheduledEvents() {
    const form = document.querySelector('form#update-filters')
    if (!form) return

    const trackId = this.hasTrackSelectTarget ? this.trackSelectTarget.value : ''
    const eventType = this.hasEventTypeSelectTarget ? this.eventTypeSelectTarget.value : ''

    const params = new URLSearchParams()
    if (trackId) params.append('track_id', trackId)
    if (eventType) params.append('event_type', eventType)

    const url = `${form.action}?${params.toString()}`

    fetch(url, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
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
        // Re-setup event listeners if we have a current target td
        // This is needed because filtering replaces the HTML, losing click handlers
        if (this.currentTargetTd) {
          this.setupAddEventListeners(this.currentTargetTd)
        }
      }
    })
    .catch(error => console.error('Error updating unscheduled events:', error))
  }

  /**
   * Adds an unschedule button (X icon) when hovering over a scheduled event
   * Button is removed on mouse leave (see handleEventMouseLeave)
   * Uses Bootstrap Icon (bi-x-circle-fill) instead of plain text
   */
  handleEventMouseEnter(event) {
    if (!event.target.classList.contains('event')) return

    const eventDiv = event.target
    if (eventDiv.querySelector('a.close')) return

    // Add unschedule button with Bootstrap icon
    const unschedule = document.createElement('a')
    unschedule.href = 'javascript:void(0)'
    unschedule.innerHTML = '<i class="bi bi-x-circle-fill"></i>'
    unschedule.className = 'close small'
    unschedule.addEventListener('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.unscheduleEvent(eventDiv)
      return false
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

  unscheduleEvent(eventDiv) {
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

  /**
   * Handles clicking on a time slot to add an event
   * Opens modal with unscheduled events, resetting filters to show all events
   * Stores the clicked td so filters can re-attach click handlers after filtering
   */
  handleTimeslotClick(event) {
    event.preventDefault()
    event.stopPropagation()

    const td = event.target
    this.currentTargetTd = td // Store for use after filtering

    if (this.hasCurrentTimeTarget) {
      this.currentTimeTarget.innerHTML = td.dataset.time || "Unknown time"
    }

    // Reset filters to show all unscheduled events when opening modal
    if (this.hasTrackSelectTarget) {
      this.trackSelectTarget.selectedIndex = 0
    }
    if (this.hasEventTypeSelectTarget) {
      this.eventTypeSelectTarget.selectedIndex = 0
    }

    // Refresh unscheduled events list (without filters)
    this.updateUnscheduledEvents()

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
      const modal = new bootstrap.Modal(this.addEventModalTarget)
      modal.show()
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
          // Reload the full event card HTML
          this.reloadEventCard(event)
        }
      })
      .catch(error => console.error('Error updating event:', error))
    }
  }

  /**
   * Reloads event card content after scheduling to show full details (speakers, track, type)
   * Fetches event JSON and rebuilds HTML to match _event.html.haml partial
   * Called after addEventToTimeSlot successfully updates the schedule
   *
   * Note: JSON structure uses 'type' not 'event_type', and 'track' is a string not object
   * Title link opens in new window (target="_blank") so scheduling interface stays open
   */
  reloadEventCard(eventElement) {
    const eventId = eventElement.id.replace('event_', '')
    const url = eventElement.dataset.showEventUrl.replace(/\/events\/\d+/, `/events/${eventId}.json`)

    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'application/json'
      }
    })
    .then(response => response.json())
    .then(event => {
      // Calculate timeslot height based on duration (event.duration is in minutes)
      // Formula matches _event.html.haml: time_slots * 20 - 7
      const timeSlots = Math.ceil(event.duration / 5) // 5 minutes per slot
      const timeslotHeight = timeSlots * 20 - 7

      // Rebuild the event card HTML to match _event.html.haml
      const colorPreview = `<div class="color-preview" style="background-color: #cccccc"></div>`
      const title = `<a href="${eventElement.dataset.showEventUrl}" target="_blank">${event.title}</a>`
      const speakers = event.speakers?.map(s => s.public_name || s.name).join(', ') || ''
      const details = `<p class="small">${speakers}${speakers ? ' ' : ''}(${event.track || ''} / ${event.type || ''})</p>`

      eventElement.innerHTML = colorPreview + title + details

      // Set CSS variable for timeslot height (used by ::after gradient for overflow indication)
      eventElement.style.setProperty('--event-timeslot-height', `${timeslotHeight}px`)

      // Reset to base event class (conflict classes are managed by update_event.js.erb)
      eventElement.className = 'event'

      this.makeDraggable(eventElement)

      // Highlight effect to indicate the card was updated
      eventElement.style.backgroundColor = '#ffff99'
      setTimeout(() => {
        eventElement.style.backgroundColor = ''
      }, 1000)
    })
    .catch(error => console.error('Error reloading event card:', error))
  }

  updateEventPosition(eventElement) {
    // Events are positioned absolutely via CSS (position: absolute, top: 0, left: 0)
    // The parent <td> has position: relative, creating a positioning context
    // This prevents event content overflow from expanding table rows and misaligning time headers
    // No JavaScript positioning needed - CSS handles it
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
