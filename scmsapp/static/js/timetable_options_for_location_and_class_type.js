// ========== Dynamically disable or enable the options in the Location selection box and class type selection box [for Add Class] ========== //
// Takes effect on the [Manager] page. Instructor is not required as it can only be changed to one-to-one lessons

document.addEventListener('DOMContentLoaded', function() {
  var classTypeSelect = document.getElementById('add_class_type');
  var locationSelect = document.getElementById('add_class_location');

  // Function to disable or enable location options based on the selected class type
  function toggleLocationOptions() {
    var selectedClassType = classTypeSelect.options[classTypeSelect.selectedIndex].getAttribute('data-class-type');
    for (var i = 0; i < locationSelect.options.length; i++) {
      var option = locationSelect.options[i];
      if (selectedClassType === 'class' && option.getAttribute('data-pool-name') === 'Lane Pool') {
        option.disabled = true;
      } else if (selectedClassType === '1-on-1' && option.getAttribute('data-pool-name') === 'Deep Pool') {
        option.disabled = true;
      } else {
        option.disabled = false;
      }
    }
  }

  // Function to disable or enable the class type option based on the selected location
  function toggleClassTypeOptions() {
    var selectedPoolName = locationSelect.options[locationSelect.selectedIndex].getAttribute('data-pool-name');
    for (var i = 0; i < classTypeSelect.options.length; i++) {
      var option = classTypeSelect.options[i];
      if (selectedPoolName === 'Deep Pool' && option.getAttribute('data-class-type') === '1-on-1') {
        option.disabled = true;
      } else if (selectedPoolName === 'Lane Pool' && option.getAttribute('data-class-type') === 'class') {
        option.disabled = true;
      } else {
        option.disabled = false;
      }
    }
  }

  // Adding a change event listener to the class type selection box
  classTypeSelect.addEventListener('change', function() {
    toggleLocationOptions();
    // If the currently selected location is disabled, reset the selection in the location check box
    if (locationSelect.options[locationSelect.selectedIndex].disabled) {
      locationSelect.selectedIndex = 0;
    }
  });

  // Add a change event listener to the position selection box
  locationSelect.addEventListener('change', function() {
    toggleClassTypeOptions();
    // If the currently selected class type is disabled, reset the check in the class type selection box
    if (classTypeSelect.options[classTypeSelect.selectedIndex].disabled) {
      classTypeSelect.selectedIndex = 0;
    }
  });

  // No values are automatically selected on page load
  classTypeSelect.selectedIndex = 0;
  locationSelect.selectedIndex = 0;

  // Initialisation options on page load
  toggleLocationOptions();
  toggleClassTypeOptions();
});


// ========== Dynamically disable or enable the options in the Location selection box and class type selection box [for Edit Class] ========== //
// Takes effect on the [Manager] page. Instructor is not required as it can only be changed to one-to-one lessons

document.addEventListener('DOMContentLoaded', function() {
  // Function to dynamically disable or enable options
  function setupModal(classId) {
    var classTypeSelect = document.getElementById('edit_modal_class_type' + classId);
    var locationSelect = document.getElementById('edit_modal_location' + classId);

    function toggleLocationOptionsBasedOnClassType() {
      var selectedClassType = classTypeSelect.options[classTypeSelect.selectedIndex].getAttribute('data-class-type');
      Array.from(locationSelect.options).forEach(function(option) {
        var poolName = option.getAttribute('data-pool-name');
        if (poolName === null) {
          // Do not disable the default "Select Location" option
          option.disabled = false;
        } else if (selectedClassType === 'class' && poolName === 'Lane Pool') {
          option.disabled = true;
        } else if (selectedClassType === '1-on-1' && poolName === 'Deep Pool') {
          option.disabled = true;
        } else {
          option.disabled = false;
        }
      });
    }

    function toggleClassTypeOptionsBasedOnLocation() {
      var selectedLocation = locationSelect.options[locationSelect.selectedIndex].getAttribute('data-pool-name');
      Array.from(classTypeSelect.options).forEach(function(option) {
        var classType = option.getAttribute('data-class-type');
        if (classType === null) {
          // Do not disable the default "Select Class Type" option
          option.disabled = false;
        } else if (selectedLocation === 'Lane Pool' && classType === 'class') {
          option.disabled = true;
        } else if (selectedLocation === 'Deep Pool' && classType === '1-on-1') {
          option.disabled = true;
        } else {
          option.disabled = false;
        }
      });
    }

    // Add event listeners
    classTypeSelect.addEventListener('change', toggleLocationOptionsBasedOnClassType);
    locationSelect.addEventListener('change', toggleClassTypeOptionsBasedOnLocation);

    // Initial check
    toggleLocationOptionsBasedOnClassType();
    toggleClassTypeOptionsBasedOnLocation();
  }

  // Attach event listeners when modal is opened
  var editModals = document.querySelectorAll('[id^="editClassModal"]');
  editModals.forEach(function(modal) {
    modal.addEventListener('shown.bs.modal', function() {
      var classId = this.getAttribute('id').replace('editClassModal', '');
      setupModal(classId);
    });
  });
});