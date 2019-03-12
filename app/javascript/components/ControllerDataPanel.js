import React from "react"
import DataPanel from "./DataPanel"

class ControllerDataPanel extends React.Component {
  renderData (data) {
    var baseURI = window.location.href;

    return (
      data.map(function(datum, index) {
        var controller = Utils.updateQueryStringParameter(baseURI, "_controller", datum.controller);
        var action = Utils.updateQueryStringParameter(baseURI, "_action", datum.action);

        return (
          <tr key={`controller-${index}`}>
            <td width="30%" className="ellipsis" key={`controller-${index}-0`}>
              <a href={controller}>{datum.controller}</a>
            </td>
            <td className="ellipsis" key={`controller-${index}-1`}>
              <a href={action}>{datum.action}</a>
            </td>
            <td width="100" key={`controller-${index}-2`}>{datum.freq}</td>
            <td width="100" key={`controller-${index}-3`}>{parseFloat(datum.avg).toFixed(2)}</td>
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

ControllerDataPanel.defaultProps = {
  title: "Controllers",
  headers: [
    "Controller",
    "Action",
    "Freq",
    "Avg"
  ]
};

export default ControllerDataPanel
