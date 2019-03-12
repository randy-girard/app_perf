import React from "react"
import DataPanel from "./DataPanel"

class DatabaseDataPanel extends React.Component {
  renderData (data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum, index) {
        var layer_url = Utils.updateQueryStringParameter(baseURI, "_layer", datum.layer_id);
        var db_url = Utils.updateQueryStringParameter(baseURI, "_sql", datum.id);

        return (
          <tr key={`host-${datum.id}`}>
            <td className="ellipsis" key={`host-${datum.id}-0`}>
              <a href={layer_url}>{datum.layer_name}</a>
            </td>
            <td className="ellipsis" key={`host-${datum.id}-1`}>
              <a href={db_url}>{datum.statement}</a>
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

DatabaseDataPanel.defaultProps = {
  title: "Database",
  headers: [
    "Layer",
    "Statement",
    "Freq",
    "Avg"
  ]
};

export default DatabaseDataPanel
