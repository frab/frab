import { Controller } from "@hotwired/stimulus"
import "range-slider-element"
import "moment"

// Connects to data-controller="availability-slider"
export default class extends Controller {
  static targets = ["checkbox", "slider", "startLabel", "endLabel", "startInput", "endInput"]
  static values = {
    dayId: Number,
    timeslotDuration: Number,
    utcOffset: Number,
    min: Number,
    max: Number,
    from: Number,
    to: Number
  }

  connect() {
    console.log("Availability slider controller connected for day", this.dayIdValue)
    this.setupCheckbox()
    this.setupSlider()
    this.initializeState()
  }

  setupCheckbox() {
    this.checkboxTarget.addEventListener('change', this.handleCheckboxChange.bind(this))
  }

  setupSlider() {
    // Configure the dual-thumb range slider element with proper structure
    this.sliderTarget.setAttribute('min', this.minValue)
    this.sliderTarget.setAttribute('max', this.maxValue)
    this.sliderTarget.setAttribute('step', this.timeslotDurationValue * 60)

    // Set initial values for dual thumbs (comma-separated values)
    const startValue = this.fromValue && this.fromValue > 0 ? this.fromValue : this.minValue
    const endValue = this.toValue && this.toValue > 0 ? this.toValue : this.maxValue
    this.sliderTarget.setAttribute('value', `${startValue},${endValue}`)

    // Listen for input and change events on the slider
    this.sliderTarget.addEventListener('input', this.handleSliderInput.bind(this))
    this.sliderTarget.addEventListener('change', this.handleSliderChange.bind(this))
  }

  initializeState() {
    const hasValidTime = this.fromValue && this.fromValue > 0
    this.checkboxTarget.checked = hasValidTime

    if (hasValidTime) {
      this.setOn()
    } else {
      this.setOff()
    }

    console.log(`Dual-thumb slider initialized for day ${this.dayIdValue}:`, {
      min: this.minValue,
      max: this.maxValue,
      from: this.fromValue,
      to: this.toValue,
      step: this.timeslotDurationValue * 60,
      value: this.sliderTarget.value
    })
  }

  handleCheckboxChange(event) {
    if (event.target.checked) {
      this.setOn()
    } else {
      this.setOff()
    }
  }

  handleSliderInput(event) {
    const values = event.target.value.split(',').map(Number)

    // Ensure we have exactly two values (start and end)
    if (values.length === 2) {
      const dates = [
        this.getDateString(values[0]),
        this.getDateString(values[1])
      ]
      const times = [
        this.getTimeString(values[0]),
        this.getTimeString(values[1])
      ]
      this.updateLabels(times)
      this.updateInputs(dates)
    }
  }

  handleSliderChange(event) {
    // Final value change - could be used for additional processing
    this.handleSliderInput(event)
  }

  getDateString(unix) {
    if (typeof moment !== 'undefined') {
      const dateFormat = 'YYYY-MM-DD HH:mm'
      const utcOffsetMinutes = this.utcOffsetValue / 60 * -1
      return moment.utc(unix * 1000).utcOffset(utcOffsetMinutes).format(dateFormat)
    } else {
      // Fallback if moment.js is not available
      const date = new Date(unix * 1000)
      // Apply timezone offset manually
      const offsetMs = this.utcOffsetValue * 1000
      const localDate = new Date(date.getTime() + offsetMs)
      return localDate.toISOString().slice(0, 16).replace('T', ' ')
    }
  }

  getTimeString(unix) {
    if (typeof moment !== 'undefined') {
      const timeFormat = 'HH:mm'
      const utcOffsetMinutes = this.utcOffsetValue / 60 * -1
      return moment.utc(unix * 1000).utcOffset(utcOffsetMinutes).format(timeFormat)
    } else {
      // Fallback if moment.js is not available
      const date = new Date(unix * 1000)
      const offsetMs = this.utcOffsetValue * 1000
      const localDate = new Date(date.getTime() + offsetMs)
      return localDate.toISOString().slice(11, 16)
    }
  }

  updateLabels(values) {
    this.startLabelTarget.textContent = values[0]
    this.endLabelTarget.textContent = values[1]
  }

  updateInputs(values) {
    this.startInputTarget.value = values[0]
    this.endInputTarget.value = values[1]
  }

  updateSliderValues(values) {
    this.sliderTarget.setAttribute('value', `${values[0]},${values[1]}`)
  }

  setSliderState(disabled) {
    this.sliderTarget.disabled = (disabled === "disable")
  }

  setOn() {
    if (this.startInputTarget.value < 0) {
      // Missing values, use min/max as default
      this.updateSliderValues([this.minValue, this.maxValue])
      const dates = [
        this.getDateString(this.minValue),
        this.getDateString(this.maxValue)
      ]
      const times = [
        this.getTimeString(this.minValue),
        this.getTimeString(this.maxValue)
      ]
      this.updateLabels(times)
      this.updateInputs(dates)
    } else {
      // Use existing values
      const startValue = this.fromValue && this.fromValue > 0 ? this.fromValue : this.minValue
      const endValue = this.toValue && this.toValue > 0 ? this.toValue : this.maxValue
      this.updateSliderValues([startValue, endValue])
      const times = [
        this.getTimeString(startValue),
        this.getTimeString(endValue)
      ]
      this.updateLabels(times)
    }
    this.setSliderState("enable")
  }

  setOff() {
    this.updateInputs(['-1', '-1'])
    this.updateSliderValues([this.minValue, this.minValue])
    this.updateLabels(['-', '-'])
    this.setSliderState("disable")
  }
}
