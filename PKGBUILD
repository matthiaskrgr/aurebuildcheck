# Maintainer: matthiaskrgr <matthias · krueger _strange_curved_character_ famsik · de
# address: run    echo "matthias · krueger _strange_curved_character_ famsik · de" | sed -e 's/\ _strange_curved_character_\ /@/' -e 's/\ ·\ /./g'

pkgname=aurebuildcheck-git
pkgver=2.5.29.g26d2a39
pkgver() {
    cd aurebuildcheck
    git describe --tags | sed -e 's/^aurebuildcheck\-//' -e 's/-/./g'
}
pkgrel=1
pkgdesc="A bash script checking aur (local) packages for needing rebuild - git version"
arch=('any')
url="https://github.com/matthiaskrgr/aurebuildcheck"
license=('GPL')
makedepends=('git')
depends=('bash' 'pacman')
source=('aurebuildcheck::git://github.com/matthiaskrgr/aurebuildcheck.git')
sha1sums=('SKIP')

package() {
  cd "$srcdir"/aurebuildcheck
  install -Dm 755 aurebuildcheck.sh "$pkgdir"/usr/bin/aurebuildcheck
}
