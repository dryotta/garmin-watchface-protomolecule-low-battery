using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.Application;

module Format {
  const INT = "%i";
  const FLOAT = "%2.0d";
}

module FieldId {
  enum {
    PRIMARY_BOTTOM,
    PRIMARY_RIGHT,
    PRIMARY_LEFT,
    SECONDARY_1,
    SECONDARY_2,
    SECONDARY_3
  }
}

module FieldType {
  enum {
    STEPS, BATTERY, CALORIES, ACTIVE_MINUTES, HEART_RATE, NOTIFICATION
  }
}

module DataFieldInfo {

  class DataFieldProperties {
    var icon;
    var text;
    var progress;

    function initialize(_icon, _text, _progress) {
      icon = _icon;
      text = _text;
      progress = _progress;
    }

  }

  function getInfoForField(fieldId) {
    switch(fieldId) {
      case FieldId.PRIMARY_BOTTOM:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldBottom"));

      case FieldId.PRIMARY_RIGHT:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldRight"));

      case FieldId.PRIMARY_LEFT:
        return getInfoForType(Application.getApp().getProperty("primaryDataFieldLeft"));

      case FieldId.SECONDARY_1:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField1"));

      case FieldId.SECONDARY_2:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField2"));

      case FieldId.SECONDARY_3:
        return getInfoForType(Application.getApp().getProperty("secondaryDataField3"));
    }
  }

  function getInfoForType(fieldType) {
    var info;
    switch(fieldType) {
      case FieldType.HEART_RATE:
        return getHeartRate();

      case FieldType.CALORIES:
        return getCalorieStats();

      case FieldType.NOTIFICATION:
        return getMessageCount();

      case FieldType.STEPS:
        return getStepStats();

      case FieldType.ACTIVE_MINUTES:
        return getActiveMinutesStats();

      case FieldType.BATTERY:
        return getBatteryStats();
    }
  }

  function getHeartRate() {
    var activityInfo = Activity.getActivityInfo();
    var heartRate = activityInfo.currentHeartRate;
    if (heartRate == null && ActivityMonitor has :getHeartRateHistory) {
      var hrHistory = ActivityMonitor.getHeartRateHistory(1, true).next(); // Try to get latest historic entry
      if (hrHistory != null) {
        heartRate = hrHistory.heartRate.format(Format.INT);
      }
    }
    if (heartRate == null) {
      heartRate = 0;
    }

    return new DataFieldProperties(1, heartRate.format(Format.INT), 0);
  }

  function getCalorieStats() {
    var current = ActivityMonitor.getInfo().calories.toDouble();

    return new DataFieldProperties(4, current.format(Format.INT), current / Application.getApp().getProperty("caloriesGoal"));
  }

  function getMessageCount() {
    return new DataFieldProperties(5, System.getDeviceSettings().notificationCount.format(Format.INT), 0);
  }

  function getBatteryStats() {
    var current = System.getSystemStats().battery;

    return new DataFieldProperties(2, current.format(Format.FLOAT) + "%", current / 100);
  }

  function getStepStats() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.steps.toDouble();

    return new DataFieldProperties(6, current.format(Format.INT), current / activityInfo.stepGoal);
  }

  function getActiveMinutesStats() {
    var activityInfo = ActivityMonitor.getInfo();
    var current = activityInfo.activeMinutesWeek.total.toDouble();

    return new DataFieldProperties(3, current.format(Format.INT), current / activityInfo.activeMinutesWeekGoal);
  }
}