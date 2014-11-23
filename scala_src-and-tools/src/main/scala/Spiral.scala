/** ********************************************************************** *
  * @author: w1gz <https://github.com/w1gz/>                               *
  * @subject: Appliance for Quarkslab's internship                        *
  * ********************************************************************** *
  * This program is free software: you can redistribute it and/or modify   *
  * it under the terms of the GNU General Public License as published by   *
  * The Free Software Foundation, either version 3 of the License, or      *
  * (at your option) any later version.                                    *
  *                                                                        *
  * This program is distributed in the hope that it will be useful,        *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of         *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
  * GNU General Public License for more details.                           *
  *                                                                        *
  * You should have received a copy of the GNU General Public License      *
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.  *
  * ************************************************************************
  */
package spiral

class Spiral(n: Int) {
  def display(tab: Array[Array[Int]]) = {
    tab foreach { row =>
      row foreach {
        // trying to make it somewhat pretty
        if (n <= 3)
          cell => print(f"$cell%1d ")
        else if (n > 3 && n <= 9)
          cell => print(f"$cell%2d ")
        else // ~33 should be a reasonable limit
          cell => print(f"$cell%3d ")
      }
      println
    }
  }

  def fill(tab: Array[Array[Int]]) = {
    var x = n / 2
    var y = x
    var first = true      // trick to set the first number, which is zero by the way
    var corner = 1        // dont bump onto wall too hard
    var ct = 0            // counter for filling out the spiral
    val ctmax = n * n - 1 // make it more readable

    def setCol(start: Int, end: Int, thatMuch: Int) = {
      for (i <- start to end by thatMuch if ct <= ctmax) {
        tab(y)(i) = ct
        ct += 1
      }
    }

    def setRow(start: Int, end: Int, thatMuch: Int) = {
      for (i <- start to end by thatMuch if ct <= ctmax) {
        tab(i)(x) = ct
        ct += 1
      }
    }

    while (ct <= ctmax) {
      if (!first) { // set the zero
        setCol(x + 1, x + corner, 1)
      } else {       // right
        setCol(x, x + corner, 1)
        first = false
      }
      x += corner

      // down
      setRow(y + 1, y + corner, 1)
      y += corner
      corner += 1

      // left
      setCol(x - 1, x - corner, -1)
      x -= corner

      // up
      setRow(y - 1, y - corner, -1)
      y -= corner
      corner += 1
    }
  }
}

object Spiral {
  def usage() = {
    println("Usage:\n\tjava -jar <jarName> <an odd number>")
    println("\te.g : java -jar spiral.jar 21")
  }

  def main(args: Array[String]) = {
    if (args.length != 1) {
      usage
      sys.exit(1984)
    }

    val n = args(0).toInt
    if (n % 2 == 0) {
      println("Stop right there silly goose ! I can't make a spiral with an even number !")
      println("Or can I... No I can't.")
      sys.exit(666)
    }

    val tab: Array[Array[Int]] = Array.ofDim(n, n)
    val spiral = new Spiral(n)

    spiral fill tab
    spiral display tab
  }
}
