module ApplicationHelper
  def dynamic_report_url(options = {}, base_params = {})
    without = options[:without]

    controller  = base_params[:controller] || params[:controller]
    action      = base_params[:action]     || params[:action]
    _host       = options[:host]           || params[:_host]
    _domain     = options[:domain]         || params[:_domain]
    _url        = options[:url]            || params[:_url]
    _controller = options[:controller]     || params[:_controller]
    _action     = options[:action]         || params[:_action]
    _layer      = options[:layer]          || params[:_layer]
    _sql        = options[:sql]            || params[:_sql]
    _st         = options[:st]             || params[:_st]
    _se         = options[:se]             || params[:_se]
    _past       = options[:_past]          || params[:_past]


    base_params.merge!(:_host       => _host)       if _host
    base_params.merge!(:_domain     => _domain)     if _domain
    base_params.merge!(:_url        => _url)        if _url
    base_params.merge!(:_controller => _controller) if _controller
    base_params.merge!(:_action     => _action)     if _action
    base_params.merge!(:_layer      => _layer)      if _layer
    base_params.merge!(:_sql        => _sql)        if _sql
    if _past
      base_params.merge!(:_past       => _past)
    elsif _st && _se
      base_params.merge!(:_st         => _st)
      base_params.merge!(:_se         => _se)
    end


    if without
      if without == "Time"
        base_params.delete(:_st)
        base_params.delete(:_se)
      else
        base_params.delete(:"_#{without.downcase}")
      end
    end

    url_for(base_params)
  end

  def selected_filters
    _host       = params[:_host]
    _domain     = params[:_domain]
    _url        = params[:_url]
    _url        = params[:_url]
    _controller = params[:_controller]
    _action     = params[:_action]
    _layer      = params[:_layer]
    _sql        = params[:_sql]
    _st         = params[:_st]
    _se         = params[:_se]
    _past       = params[:_past]

    base_params = {}
    base_params.merge!("Domain"     => _domain)     if _domain
    base_params.merge!("Url"        => _url)        if _url
    base_params.merge!("Controller" => _controller) if _controller
    base_params.merge!("Action"     => _action)     if _action

    if _host
      host = @current_application.hosts.find(_host)
      base_params.merge!("Host" => host.name)
    end

    if _layer
      layer = @current_application.layers.find(_layer)
      base_params.merge!("Layer" => layer.name)
    end

    if _sql
      database_call = @current_application.database_calls.find(_sql)
      base_params.merge!("SQL" => database_call.statement)
    end

    if _st && _se
      st = Time.at(_st.to_i).strftime("%I:%M:%S")
      se = Time.at(_se.to_i).strftime("%I:%M:%S")
      base_params.merge!("Time" => "#{st} to #{se}")
    end

    base_params
  end
end
