import React from "react"
import DataPanel from "./DataPanel"

class HostDataPanel extends React.Component {
  renderData (data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum, index) {
        var url = Utils.updateQueryStringParameter(baseURI, "_host", datum.id);

        return (
          <tr key={`host-${datum.id}`}>
            <td className="ellipsis" key={`host-${datum.id}-0`}>
              <a href={url}>{datum.name}</a>
            </td>
            <td width="100" key={`host-${datum.id}-2`}>{datum.freq}</td>
            <td width="100" key={`host-${datum.id}-3`}>{parseFloat(datum.avg).toFixed(2)}</td>
          </tr>
        )
      })
    )
  }

  render () {
    return (
      <DataPanel headers={this.props.headers}
                 title={this.props.title}
                 url={this.props.url}
                 callback={this.renderData} />
    )
  }
}

HostDataPanel.defaultProps = {
  title: "Hosts",
  headers: [
    "Host",
    "Freq",
    "Avg"
  ]
};

export default HostDataPanel
