// [Edit Class] popups for [Instructor] roles only, with automatic course end time setting

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('[id^="edit_modal_start_time"]').forEach(function(startTimeInput) {
    startTimeInput.addEventListener('change', function() {
      // Get the id of the current class
      let classId = this.id.match(/\d+/)[0];
      // Calculate new end time
      let startTime = new Date(this.value);
      startTime.setMinutes(startTime.getMinutes() + 30);
      // Manual construction of datetime strings to avoid time zone issues
      let year = startTime.getFullYear();
      let month = ('0' + (startTime.getMonth() + 1)).slice(-2); // January is 0!
      let day = ('0' + startTime.getDate()).slice(-2);
      let hours = ('0' + startTime.getHours()).slice(-2);
      let minutes = ('0' + startTime.getMinutes()).slice(-2);
      let endTimeFormatted = `${year}-${month}-${day}T${hours}:${minutes}`;
      // Update end time input box
      document.querySelector(`#edit_modal_end_time${classId}`).value = endTimeFormatted;
    });
  });
});