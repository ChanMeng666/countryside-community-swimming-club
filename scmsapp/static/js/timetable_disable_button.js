// ========== Disable Edit and Delete buttons [for Instructor] ========== //
// If it is class, the Edit button and Delete button are disabled.
document.addEventListener('DOMContentLoaded', function() {
  // Define the class_type IDs that should disable the Edit and Delete buttons
  var disabledClassTypeIds = ['1', '2', '3', '4'];

  // Function to check and disable buttons based on class_type ID
  function disableButtonsIfNecessary(buttons) {
    buttons.forEach(function(button) {
      var classTypeId = button.getAttribute('data-class-type-id');
      if (disabledClassTypeIds.includes(classTypeId)) {
        button.disabled = true; // Disable button if class_type ID matches
      }
    });
  }

  // Get all Edit and Delete buttons
  var editButtons = document.querySelectorAll('.edit-btn');
  var deleteButtons = document.querySelectorAll('.delete-btn');

  // Disable buttons as necessary
  disableButtonsIfNecessary(editButtons);
  disableButtonsIfNecessary(deleteButtons);
});