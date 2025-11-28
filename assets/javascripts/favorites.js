// Инициализация функциональности избранных задач
$(document).ready(function() {
  // Перемещаем кнопку избранного в область действий на странице задачи
  function moveFavoriteButtonToActions() {
    var $favoriteButton = $('.favorite-issue-button').first();
    if ($favoriteButton.length > 0) {
      // Ищем область действий в заголовке задачи (первый .contextual в #content, не в истории)
      var $actions = $('#content > .contextual').first();
      if ($actions.length > 0) {
        // Если кнопка еще не перемещена
        if ($actions.find('.icon-favorite, .icon-favorite-off').length === 0) {
          var $link = $favoriteButton.find('a');
          if ($link.length > 0) {
            // Вставляем кнопку в начало области действий
            $actions.prepend($link.clone());
            $actions.prepend(' ');
          }
        }
        // Скрываем оригинальный контейнер
        $favoriteButton.hide();
      } else {
        // Если область действий не найдена, показываем кнопку на месте
        $favoriteButton.show();
      }
    }
  }

  // Вызываем функцию при загрузке страницы
  moveFavoriteButtonToActions();

  // Также вызываем при динамической загрузке контента
  $(document).on('ajax:complete', moveFavoriteButtonToActions);
  
  // Добавляем колонку избранного в таблицу задач (после checkbox, перед номером)
  function addFavoriteColumn() {
    var $issuesTable = $('.list.issues');
    if ($issuesTable.length > 0) {
      // Добавляем заголовок колонки после checkbox
      var $headerRow = $issuesTable.find('thead tr');
      if ($headerRow.find('th.favorite-issue-icon').length === 0) {
        var $checkboxTh = $headerRow.find('th.checkbox').first();
        if ($checkboxTh.length > 0) {
          $checkboxTh.after('<th class="favorite-issue-icon" title="' + 'Избранное' + '"></th>');
        }
      }

      // Перемещаем td.favorite-issue-icon после td.checkbox в каждой строке
      $issuesTable.find('tbody tr[id^="issue-"]').each(function() {
        var $row = $(this);
        var $favoriteTd = $row.find('td.favorite-issue-icon');
        var $checkboxTd = $row.find('td.checkbox').first();

        if ($favoriteTd.length > 0 && $checkboxTd.length > 0) {
          // Перемещаем после checkbox, если она еще не там
          if ($favoriteTd.prev()[0] !== $checkboxTd[0]) {
            $favoriteTd.detach().insertAfter($checkboxTd);
          }
        }
      });

      // Обновляем colspan для группировочных строк
      var expectedColspan = $headerRow.find('th').length;
      $issuesTable.find('tr.group td[colspan]').each(function() {
        var $td = $(this);
        var currentColspan = parseInt($td.attr('colspan'));
        if (currentColspan !== expectedColspan) {
          $td.attr('colspan', expectedColspan);
        }
      });
    }
  }

  // Вызываем при загрузке страницы
  addFavoriteColumn();

  // Также вызываем при динамической загрузке контента
  $(document).on('ajax:complete', addFavoriteColumn);
  
  // Обработчик клика по кнопке избранного
  $(document).on('click', '.icon-favorite, .icon-favorite-off', function(e) {
    e.preventDefault();
    var $link = $(this);
    var url = $link.attr('href');
    var method = ($link.data('method') || 'post').toString().toUpperCase();

    // Показываем индикатор загрузки
    $('#ajax-indicator').show();

    // Добавляем класс для визуальной индикации процесса
    $link.addClass('processing');

    // Отправляем AJAX запрос для добавления/удаления из избранного
    $.ajax({
      url: url,
      type: method,
      dataType: 'script',
      success: function(response) {
        // Обработка успешного ответа происходит в JS шаблонах
        // Удаляем класс обработки
        $link.removeClass('processing');
      },
      error: function(xhr, status, error) {
        console.error('Ошибка при обновлении избранного:', error);
        // Удаляем класс обработки
        $link.removeClass('processing');
        // Скрываем индикатор загрузки
        $('#ajax-indicator').hide();
        // Показываем сообщение об ошибке
        $('#flash_error').html('Произошла ошибка при обновлении избранного');
        $('#flash_error').show();
      }
    });
  });
  
  // Обработчик для массового добавления/удаления избранных задач через контекстное меню
  $(document).on('click', 'a[href*="favorite_issues"]', function(e) {
    // Проверяем, что это ссылка из контекстного меню
    if ($(this).closest('#context-menu').length > 0 || $(this).hasClass('context-menu-link')) {
      e.preventDefault();
      var $link = $(this);
      var url = $link.attr('href');
      var method = $link.data('method') || ($link.attr('data-method') || 'post').toLowerCase();
      
      // Показываем индикатор загрузки
      $('#ajax-indicator').show();
      
      // Отправляем AJAX запрос для массового добавления/удаления из избранного
      $.ajax({
        url: url,
        type: method.toUpperCase(),
        dataType: 'script',
        success: function(response) {
          // Обработка успешного ответа происходит в JS шаблонах
          // Закрываем контекстное меню после выполнения действия
          if (typeof contextMenuHide === 'function') {
            contextMenuHide();
          }
        },
        error: function(xhr, status, error) {
          console.error('Ошибка при массовом обновлении избранного:', error);
          // Скрываем индикатор загрузки
          $('#ajax-indicator').hide();
          // Показываем сообщение об ошибке
          $('#flash_error').html('Произошла ошибка при массовом обновлении избранного');
          $('#flash_error').show();
          if (typeof contextMenuHide === 'function') {
            contextMenuHide();
          }
        }
      });
    }
  });
  
  // Обработчик для автоматического скрытия уведомлений через 5 секунд
  $(document).ajaxSuccess(function() {
    setTimeout(function() {
      $('#flash_notice, #flash_error').fadeOut('slow');
    }, 5000);
  });
});