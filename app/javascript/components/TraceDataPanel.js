import React from "react"
import DataPanel from "./DataPanel"

class TraceDataPanel extends React.Component {
  constructor(props) {
    super(props)
  }

  renderData (data, props) {
    var that = this;
    return (
      data.map(function(datum, index) {
        var url = props.traces_url + "/" + datum.trace_key;

        return (
          <tr key={`host-${datum.id}`}>
            <td className="ellipsis" key={`host-${datum.id}-0`}>
              <a href={url}>{datum.url || datum.trace_key}</a>
            </td>
            <td width="100" key={`host-${datum.id}-2`}>{parseFloat(datum.duration).toFixed(2)}</td>
            <td width="120" key={`host-${datum.id}-3`}>{moment(datum.timestamp).fromNow()}</td>
          </tr>
        )
      })
    )
  }

  render () {
    return (
      <DataPanel headers={this.props.headers}
                 showHeaderButtons={false}
                 title={this.props.title}
                 url={this.props.url}
                 callback={this.renderData} />
    )
  }
}

TraceDataPanel.defaultProps = {
  title: "Traces (Most Consuming)",
  headers: []
};

export default TraceDataPanel
