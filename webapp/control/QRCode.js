sap.ui.define(["sap/ui/core/Control"], function (Control) {
  "use strict";
  var _loading;

  function loadLib(sUrl) {
    if (window.qrcode) { return Promise.resolve(); }
    if (!_loading) {
      _loading = new Promise(function (resolve, reject) {
        var s = document.createElement("script");
        s.src = sUrl;
        s.onload = resolve;
        s.onerror = reject;
        document.head.appendChild(s);
      });
    }
    return _loading;
  }

  return Control.extend("zr40.project1.control.QRCode", {
    metadata: {
      properties: {
        bookingId: { type: "string", defaultValue: "" },
        cellSize: { type: "int", defaultValue: 5 }
      }
    },
    renderer: {
      apiVersion: 2,
      render: function (rm, oControl) {
        rm.openStart("div", oControl).openEnd();
        rm.openStart("div", oControl.getId() + "-qr").openEnd().close("div");
        rm.openStart("div", oControl.getId() + "-info")
          .style("margin-top", "0.5rem").openEnd().close("div");
        rm.close("div");
      }
    },
    onAfterRendering: function () {
      var that = this;
      var sBooking = this.getBookingId();
      var oQr = document.getElementById(this.getId() + "-qr");
      var oInfo = document.getElementById(this.getId() + "-info");
      var oModel = this.getModel();
      oQr.innerHTML = "";
      oInfo.textContent = "";
      if (!sBooking || !oModel) { return; }

      oModel.read("/Invoice('INV-" + sBooking + "')", {
        success: function (oData) {
          if (!oData.QrTlv) {
            oInfo.textContent = "Invoice " + oData.InvoiceId + " has no QR yet.";
            return;
          }
          loadLib(sap.ui.require.toUrl("zr40/project1/libs/qrcode.js")).then(function () {
            var qr = window.qrcode(0, "M");
            qr.addData(oData.QrTlv);
            qr.make();
            oQr.innerHTML = qr.createImgTag(that.getCellSize(), 8);
            oInfo.textContent = "Invoice " + oData.InvoiceId +
              " | Total " + oData.TotalAmount + " " + oData.Waers +
              " | VAT " + oData.VatAmount;
          });
        },
        error: function () {
          oInfo.textContent = "No invoice for this booking yet.";
        }
      });
    }
  });
});