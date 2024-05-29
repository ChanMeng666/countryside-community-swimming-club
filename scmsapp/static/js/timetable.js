// For [Manager and Instructor] roles

// ========== Limitations on input conditions for date and time for [Add Class and Edit Class] ========== //
document.addEventListener('DOMContentLoaded', function() {
  var today = new Date();
  var yyyy = today.getFullYear();
  var mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0!
  var dd = String(today.getDate()).padStart(2, '0');

  // ---------- Function to check if the date is a holiday ----------
  function isHoliday(date) {
    var christmasDay = yyyy + '-12-25';
    var boxingDay = yyyy + '-12-26';
    return date === christmasDay || date === boxingDay;
  }

  // ---------- Function to set the min attribute to today's date ----------
  function setMinDate(input) {
    var minDate = yyyy + '-' + mm + '-' + dd;
    input.setAttribute('min', minDate + 'T06:00');
  }

  // ---------- Function to validate the input value ----------
  function validateDateTime(input) {
    var date = input.value.split('T')[0];
    var time = input.value.split('T')[1];

    // Check if the selected date is a holiday
    if (isHoliday(date)) {
      alert('Christmas Day and Boxing Day are not selectable.');
      input.value = ''; // Reset the value
      return;
    }

    // Check if the time is within the allowed range
    if (time < '06:00' || time > '20:00') {
      alert('Time must be between 06:00 and 20:00.');
      input.value = ''; // Reset the value
    }
  }

  // Get all datetime-local inputs
  var dateTimeInputs = document.querySelectorAll('input[type=datetime-local]');

  dateTimeInputs.forEach(function(input) {
    setMinDate(input); // Set the min attribute to today

    // Add event listener to validate date and time
    input.addEventListener('change', function() {
      validateDateTime(this);
    });
  });
});


// ========== Automatically setting the end time based on the start time and class type for [Add Class] [Manager and Instructor] ========== //
document.addEventListener('DOMContentLoaded', function() {
  // ---------- Function to check for class overlap ----------
  function checkClassOverlap() {
    var locationSelect = document.getElementById('add_class_location');
    var startTimeInput = document.getElementById('start_time_datetime-local');
    var endTimeInput = document.getElementById('end_time_datetime-local');
    var instructorId = document.getElementById('hidden_instructor_id') ? document.getElementById('hidden_instructor_id').value : document.getElementById('add_class_instructor').value;

    var locationId = locationSelect.value;
    var startTime = startTimeInput.value;
    var endTime = endTimeInput.value;

    // Make sure all selections are made
    if (!locationId || !startTime || !endTime) return;

    var requestBody = {location_id: locationId, start_time: startTime, end_time: endTime, instructor_id: instructorId};

    // Send the request to check for overlap
    fetch('/check_for_overlap', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(requestBody)
    })
    .then(response => {
      if (!response.ok) {
        throw response;
      }
      return response.json();
    })
    .then(data => {
      if (data.error) {
        alert(data.error);
        // Reset the location and time fields
        locationSelect.value = '';
        startTimeInput.value = '';
        endTimeInput.value = '';
      }
    })
    .catch(errorResponse => {
      // Handle error response
      errorResponse.json().then(errorData => {
        alert(errorData.error);
      });
    });
  }

  // Add event listeners for location and time inputs
  document.getElementById('add_class_location').addEventListener('change', checkClassOverlap);
  document.getElementById('start_time_datetime-local').addEventListener('change', checkClassOverlap);
  document.getElementById('end_time_datetime-local').addEventListener('change', checkClassOverlap);

  // ---------- Function: Automatically set end time based on start time and course type ----------
  function autoSetEndTime() {
    var startTimeInput = document.getElementById('start_time_datetime-local');
    var classTypeSelect = document.getElementById('add_class_type');
    var endTimeInput = document.getElementById('end_time_datetime-local');

    if (!startTimeInput.value) return; // If the start time is not set, no action is performed

    var startTime = new Date(startTimeInput.value);
    var classType = classTypeSelect.options[classTypeSelect.selectedIndex].getAttribute('data-class-type');

    // Additional time based on type of class
    if (classType === 'class') {
      startTime.setMinutes(startTime.getMinutes() + 60); // Increase 60 minutes
    } else if (classType === '1-on-1') {
      startTime.setMinutes(startTime.getMinutes() + 30); // Increase 30 minutes
    }

    // Check that the end time is not longer than 20:00
    if (startTime.getHours() > 20 || (startTime.getHours() === 20 && startTime.getMinutes() > 0)) {
      alert('End time must be by 20:00.');
      startTimeInput.value = ''; // Reset start time
      endTimeInput.value = ''; // Reset end time
      return;
    }

    // Setting the value of the end time input box
    var yyyy = startTime.getFullYear();
    var mm = String(startTime.getMonth() + 1).padStart(2, '0'); // January is 0!
    var dd = String(startTime.getDate()).padStart(2, '0');
    var hh = String(startTime.getHours()).padStart(2, '0');
    var min = String(startTime.getMinutes()).padStart(2, '0');
    endTimeInput.value = `${yyyy}-${mm}-${dd}T${hh}:${min}`;

    // After setting end time, check if there's any overlap with existing classes
    checkClassOverlap();
  }

  // Listen for changes to the start time and course type selection to automatically update the end time
  document.getElementById('start_time_datetime-local').addEventListener('change', autoSetEndTime);
  document.getElementById('add_class_type').addEventListener('change', autoSetEndTime);

});


// ========== Automatically setting the end time based on the start time and class type for [Edit Class] ========== //
document.addEventListener('DOMContentLoaded', function() {

  // Function to check for class overlap for Edit Class modal
  function checkClassOverlapForEdit(classId) {
    var locationSelect = document.getElementById('edit_modal_location' + classId);
    var startTimeInput = document.getElementById('edit_modal_start_time' + classId);
    var endTimeInput = document.getElementById('edit_modal_end_time' + classId);
    var instructorId = document.getElementById('hidden_instructor_id') ? document.getElementById('hidden_instructor_id').value : document.getElementById('edit_modal_instructor' + classId) ? document.getElementById('edit_modal_instructor' + classId).value : null;


    var locationId = locationSelect.value;
    var startTime = startTimeInput.value;
    var endTime = endTimeInput.value;

    if (!locationId || !startTime || !endTime) return;

    var requestBody = {
      location_id: locationId,
      start_time: startTime,
      end_time: endTime,
      instructor_id: instructorId,
      class_id: classId
    };

    fetch('/check_for_overlap', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(requestBody)
    })
    .then(response => {
      if (!response.ok) {
        throw response;
      }
      return response.json();
    })
    .then(data => {
      if (data.error) {
        alert(data.error);
        locationSelect.value = '';
        startTimeInput.value = '';
        endTimeInput.value = '';
      }
    })
    .catch(errorResponse => {
      errorResponse.json().then(errorData => {
        alert(errorData.error);
      });
    });
  }


  // ---------- Function: Automatically set end time based on start time and course type for each class ----------
  // * Open a new js file to write the instructor's edit class to automatically increase the end time.

  function autoSetEndTimeForClass(classId) {
    var startTimeInput = document.getElementById('edit_modal_start_time' + classId);
    var classTypeSelect = document.getElementById('edit_modal_class_type' + classId);
    var endTimeInput = document.getElementById('edit_modal_end_time' + classId);

    if (!startTimeInput.value) return; // If the start time is not set, no action is performed

    var startTime = new Date(startTimeInput.value);
    var classType = classTypeSelect.options[classTypeSelect.selectedIndex].getAttribute('data-class-type');

    // Additional time based on type of class
    if (classType === 'class') {
      startTime.setMinutes(startTime.getMinutes() + 60); // Increase 60 minutes
    } else if (classType === '1-on-1') {
      startTime.setMinutes(startTime.getMinutes() + 30); // Increase 30 minutes
    }

    // Setting the value of the end time input box
    var yyyy = startTime.getFullYear();
    var mm = String(startTime.getMonth() + 1).padStart(2, '0'); // January is 0!
    var dd = String(startTime.getDate()).padStart(2, '0');
    var hh = String(startTime.getHours()).padStart(2, '0');
    var min = String(startTime.getMinutes()).padStart(2, '0');
    endTimeInput.value = `${yyyy}-${mm}-${dd}T${hh}:${min}`;
  }

  // Listen for changes in each class's start time and class type selection to automatically update the end time
  // We will need to call this function for each class's modal when it is shown
  var editClassModals = document.querySelectorAll('[id^="editClassModal"]');
  editClassModals.forEach(function(modal) {
    modal.addEventListener('shown.bs.modal', function() {
      var classId = this.getAttribute('id').replace('editClassModal', '');
      var locationSelect = document.getElementById('edit_modal_location' + classId);
      var startTimeInput = document.getElementById('edit_modal_start_time' + classId);
      var endTimeInput = document.getElementById('edit_modal_end_time' + classId);


      // This may be null for instructor's personal page
      var instructorSelect = document.getElementById('edit_modal_instructor' + classId);
      var classTypeSelect = document.getElementById('edit_modal_class_type' + classId);

      // Initially check for overlap when the modal is opened
      checkClassOverlapForEdit(classId);

      // Add event listeners for changes
      if (locationSelect) {
        locationSelect.addEventListener('change', function() {
          checkClassOverlapForEdit(classId);
        });
      }
      if (startTimeInput) {
        startTimeInput.addEventListener('change', function() {
          checkClassOverlapForEdit(classId);
        });
      }
      if (endTimeInput) {
        endTimeInput.addEventListener('change', function() {
          checkClassOverlapForEdit(classId);
        });
      }
      // Only add this event listener if the instructorSelect exists (manager's page)
      if (instructorSelect) {
        instructorSelect.addEventListener('change', function() {
          checkClassOverlapForEdit(classId);
        });
      }

      // Initially set end time when the modal is opened
      autoSetEndTimeForClass(classId);

      // Add event listeners for changes
      startTimeInput.addEventListener('change', function() {
        autoSetEndTimeForClass(classId);
      });

      classTypeSelect.addEventListener('change', function() {
        autoSetEndTimeForClass(classId);
      });
    });
  });
});


// ========== Input Style for Time Input Box ========== //
function adjustTime(input) {
    const value = input.value;
    const classId = input.id.replace('edit_modal_start_time', '');

    if (value) {
        const localDate = new Date(value);
        const minutes = localDate.getMinutes();
        const closestHalfHour = minutes >= 30 ? 30 : 0;
        localDate.setMinutes(closestHalfHour, 0, 0);  // Reset seconds and milliseconds

        // Compensate for timezone offset
        const timezoneOffset = localDate.getTimezoneOffset() * 60000;
        const adjustedDate = new Date(localDate.getTime() - timezoneOffset);

        input.value = adjustedDate.toISOString().slice(0, 16);
    }

    // Call autoSetEndTimeForClass after adjusting the time
    autoSetEndTimeForClass(classId);
}

// Ensure the step is set correctly on page load
document.addEventListener('DOMContentLoaded', function() {
    adjustTime(document.getElementById('start_time_datetime-local'));
});


// Bind adjustTime function to the onchange event of each Start Time input
document.querySelectorAll('[id^="edit_modal_start_time"]').forEach(function(startTimeInput) {
  startTimeInput.addEventListener('change', function() {
    adjustTime(this);
  });
});


// ========== Dynamically setting the max="" property of the [Open Slot] input box ========== //
document.addEventListener('DOMContentLoaded', function() {
  var classTypeSelect = document.getElementById('add_class_type');
  var openSlotInput = document.getElementById('open_slot');

  // ---------- Function to adjust the max attribute for the open_slot input ----------
    function adjustMaxSlots(classTypeSelect, openSlotInput) {
    var selectedClassType = classTypeSelect.options[classTypeSelect.selectedIndex].text;
    if (selectedClassType.toLowerCase().includes('1-on-1')) {
      openSlotInput.max = '1';
    } else if (selectedClassType.toLowerCase().includes('class')) {
      openSlotInput.max = '15';
    }
  }

    // Initial adjustment when the page loads for Add Class
    if (classTypeSelect && openSlotInput) {
      adjustMaxSlots(classTypeSelect, openSlotInput);
      // Event listener for changes on the class type select for Add Class
      classTypeSelect.addEventListener('change', function() {
        adjustMaxSlots(classTypeSelect, openSlotInput);
      });
    }

    // Event listener for changes on the class type select for Edit Class
    $('[id^="editClassModal"]').each(function() {
      var modal = $(this);
      modal.on('shown.bs.modal', function() {
        var classId = this.id.replace('editClassModal', '');
        var editClassTypeSelect = document.getElementById('edit_modal_class_type' + classId);
        var editOpenSlotInput = document.getElementById('edit_modal_open_slot' + classId);

        if (editClassTypeSelect && editOpenSlotInput) {
          adjustMaxSlots(editClassTypeSelect, editOpenSlotInput);
          editClassTypeSelect.addEventListener('change', function() {
            adjustMaxSlots(editClassTypeSelect, editOpenSlotInput);
          });
        }
      });
    });
});


// ========== Timetable Class Button -- Colour display style ==========//
// ---------- Function to get the class type and return the corresponding button class ----------
function getButtonClass(classType) {
  switch(classType) {
    case 1:
      return "btn btn-primary";
    case 2:
      return "btn btn-success";
    case 3:
      return "btn btn-danger";
    case 4:
      return "btn btn-warning";
    case 5:
        return "btn btn-outline-primary";
    case 6:
        return "btn btn-outline-info";
    case 7:
        return "btn btn-outline-success";
    case 8:
        return "btn btn-outline-danger";
    case 9:
        return "btn btn-outline-warning";
    default:
      return "btn btn-outline-dark";
  }
}

document.addEventListener('DOMContentLoaded', function() {
  var buttons = document.querySelectorAll('.class-button');
  buttons.forEach(function(button) {
    var classType = parseInt(button.dataset.classType);
    button.className = getButtonClass(classType);
  });
});

