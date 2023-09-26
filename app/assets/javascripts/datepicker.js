$(document).ready(function () {
  flatpickr("#datepicker", {
    minDate: Date.now(),
  });

  flatpickr("#timepicker", {
    noCalendar: true,
    enableTime: true,
    dateFormat: "h:i K",
  });
});