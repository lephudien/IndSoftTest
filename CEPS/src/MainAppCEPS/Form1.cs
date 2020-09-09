using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MainAppCEPS
{
  public partial class Form1 : Form
  {
    public Form1()
    {
      InitializeComponent();
    }

    private void button1_Click(object sender, EventArgs e)
    {
      CEPSModules1.Class1 cls1 = new CEPSModules1.Class1();
      var resp = cls1.GetResponse();

      System.Windows.Forms.MessageBox.Show("AuthorizationStatus: " + resp.AuthorizationStatus);
    }
  }
}
