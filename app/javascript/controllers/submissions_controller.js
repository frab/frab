import { Controller } from "@hotwired/stimulus"
import "flot/jquery.flot"
import "flot/jquery.flot.time"

// Connects to data-controller="submissions"
export default class extends Controller {
  static targets = ["submissionGraph", "submissionSumGraph"]
  static values = { data: Array }

  connect() {
    console.log("Submissions controller connected")
    this.renderCharts()
  }

  renderCharts() {
    if (this.dataValue.length > 0) {
      this.renderSubmissionGraph()
      this.renderSubmissionSumGraph()
    }
  }

  renderSubmissionGraph() {
    if (!this.hasSubmissionGraphTarget) return

    $.plot($(this.submissionGraphTarget), [this.dataValue], {
      xaxis: { mode: "time" }
    })
  }

  renderSubmissionSumGraph() {
    if (!this.hasSubmissionSumGraphTarget) return

    const sumData = this.dataValue.reduce((accumulator, point) => {
      const previousSum = accumulator.length > 0 ? accumulator[accumulator.length - 1][1] : 0
      return accumulator.concat([[point[0], point[1] + previousSum]])
    }, [])

    $.plot($(this.submissionSumGraphTarget), [sumData], {
      xaxis: { mode: "time" }
    })
  }
}
