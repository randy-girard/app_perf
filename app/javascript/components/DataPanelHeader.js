import React from "react"

class DataPanelHeader extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      order: "FreqAvg"
    };
  }

  changeOrder = (e) => {
    e.preventDefault();

    var order = e.target.getAttribute("data-order");
    this.setState(
      { order: order },
      function() {
        this.props.updateData(this.state);
      }
    );
  }

  render () {
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
}
export default DataPanelHeader
