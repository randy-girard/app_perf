import React from "react"

class DataPanelFooter extends React.Component {
  changeLimit = (e) => {
    e.preventDefault();

    var limit = e.target.getAttribute("data-limit");
    this.setState(
      { limit: limit },
      function() {
        this.props.updateData(this.state);
      }
    );
  }

  render () {
    return (
      <div className="box-footer">
        Show
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="10">10</a>
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="20">20</a>
        &nbsp;&nbsp;<a href="#" onClick={this.changeLimit} data-limit="50">50</a>
      </div>
    )
  }
}
export default DataPanelFooter
