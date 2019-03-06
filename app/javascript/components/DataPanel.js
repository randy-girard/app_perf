import React from "react"
import DataPanelHeader from "./DataPanelHeader"
import DataPanelFooter from "./DataPanelFooter"
import DataPanelBody from "./DataPanelBody"
import LoadingDataPanel from "./LoadingDataPanel"

import axios from 'axios';

class DataPanel extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      loading: true,
      data: [],
      limit: 10,
      order: "traces*(hits/traces)"
    };
  }

  updateData = (state) => {
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
  }

  componentDidMount () {
    this.updateData(this.state);
  }

  componentWillUnmount () {
    this.serverRequest.abort();
  }

  render () {
    var body = "";

    return (
      <div className="box">
        <DataPanelHeader title={this.props.title} updateData={this.updateData} showHeaderButtons={this.props.showHeaderButtons} />
        {this.state.loading ? (
          <LoadingDataPanel />
        ) : (<div></div>)}
        <DataPanelBody headers={this.props.headers}
                       url={this.props.url}>
          {this.props.callback(this.state.data, this.props)}
        </DataPanelBody>
        <DataPanelFooter updateData={this.updateData} />
      </div>
    )
  }
}
export default DataPanel
