using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace AppClientCEPS
{
  static class Program
  {
    /// <summary>
    /// The main entry point for the application.
    /// </summary>
    [STAThread]
    static void Main()
    {
      Application.EnableVisualStyles();
      Application.SetCompatibleTextRenderingDefault(false);
      Application.Run(new Form1());

      CEPSModules1.Class1 cls1 = new CEPSModules1.Class1();
      cls1.RunTests();

      // Test git - master edit
      int i = 1;
      i += 57;
    }
  }
}
