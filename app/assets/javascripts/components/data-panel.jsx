window.DataPanelHeader = React.createClass({
  getInitialState: function() {
    return {
      order: "FreqAvg"
    }
  },

  changeOrder: function(e) {
    e.preventDefault();

    var order = e.target.getAttribute("data-order");
    this.setState(
      { order: order },
      function() {
        this.props.updateData(this.state);
      }
    );
  },

  render: function() {
    return (
      <div className="box-header">
        <h3 className="box-title">{this.props.title}</h3>
        {this.props.showHeaderButtons !== false ? (
        <div className="box-tools pull-right">
          <div className="btn-group" data-toggle="btn-toggle">
            <a onClick={this.changeOrder} data-order="FreqAvg" className={`btn btn-default btn-sm ${(this.state.order === "FreqAvg") ? 'active' : ''}`}>Freq X Avg</a>
            <a onClick={this.changeOrder} data-order="Freq" className={`btn btn-default btn-sm ${(this.state.order === "Freq") ? 'active' : ''}`}>Freq</a>
            <a onClick={this.changeOrder} data-order="Avg" className={`btn btn-default btn-sm ${(this.state.order === "Avg") ? 'active' : ''}`}>Avg</a>
          </div>
        </div>
        ) : (<div />)}
      </div>
    )
  }
});

window.DataPanelFooter = React.createClass({
  changeLimit: function(e) {
    e.preventDefault();

    var limit = e.target.getAttribute("data-limit");
    this.setState(
      { limit: limit },
      function() {
        this.props.updateData(this.state);
      }
    );
  },
  render: function() {
    return (
      <div className="box-footer">
        Show
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="10">10</a>
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="20">20</a>
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="50">50</a>
      </div>
    )
  }
});

window.DataPanelBody = React.createClass({
  goToPage: function(e) {
    this.props.router.push('/some/location');
  },

  render: function() {
    return (
      <div className="box-body">
        <table className="table table-condensed">
          <thead>
            <tr>
              {this.props.headers.map(function(header) {
                return (
                  <th key={header}>{header}</th>
                )
              })}
            </tr>
          </thead>
          <tbody>
            {this.props.children}
          </tbody>
        </table>
      </div>
    )
  }
});

window.LoadingDataPanel = React.createClass({
  render: function() {
    return (
      <div className='overlay'>
        <i className='fa fa-spinner fa-spin'></i>
      </div>
    )
  }
})

window.DataPanel = React.createClass({
  getInitialState: function() {
    return {
      loading: true,
      data: [],
      limit: 10,
      order: "traces*(hits/traces)"
    }
  },

  updateData: function(state) {
    var _this = this;

    _this.state.loading = true;

    _this.setState(Object.assign(_this.state, state), function() {
      _this.serverRequest =
        axios({
          method: 'get',
          url: _this.props.url,
          params: {
            "_order": this.state.order,
            "_limit": this.state.limit
          }
        }).then(function(result) {
          _this.setState({
            loading: false,
            data: result.data.data
          });
        });
    });
  },

  componentDidMount: function() {
    this.updateData(this.state);
  },

  componentWillUnmount: function() {
    this.serverRequest.abort();
  },

  render: function() {
    var body = "";

    return (
      <div className="box">
        <DataPanelHeader title={this.props.title} updateData={this.updateData} showHeaderButtons={this.props.showHeaderButtons} />
        {this.state.loading ? (
          <LoadingDataPanel />
        ) : (<div></div>)}
        <DataPanelBody headers={this.props.headers}
                       url={this.props.url}>
          {this.props.callback(this.state.data)}
        </DataPanelBody>
        <DataPanelFooter updateData={this.updateData} />
      </div>
    )
  }
});
