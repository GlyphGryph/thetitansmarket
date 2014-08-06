module ApplicationHelper

  def format_time(time)
    # Format a time that was in seconds
    time_seconds = time
    time_minutes, time_seconds = time_seconds.divmod(60)
    time_hours, time_minutes = time_minutes.divmod(60)
    time_days, time_hours = time_hours.divmod(60)
    time_string = ""
    time_started = false
    if(time_days > 0)
      time_started = true
      time_string +="#{time_days} days, "
    end
    if(time_hours > 0 || time_started)
      time_started = true
      time_string +="#{time_hours} hours, "
    end
    if(time_minutes > 0 || time_started)
      time_started = true
      time_string +="#{time_minutes} minutes, "
    end
    if(time_seconds > 0 || time_started)
      time_started = true
      time_string +="#{time_seconds.floor} seconds"
    end
    return time_string
  end
end
