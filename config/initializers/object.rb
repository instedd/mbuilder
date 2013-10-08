# Copyright (C) 2010-2012, InSTEDD
#
# This file is part of Verboice.
#
# Verboice is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Verboice is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Verboice.  If not, see <http://www.gnu.org/licenses/>.

class Object
  def not_nil?
    !nil?
  end

  def is_an? object
    is_a? object
  end

  def subclass_responsibility
    raise 'Subclasses must redefine this method'
  end

  def self.subclass_responsibility(*args)
    args.each do |method|
      self.class_eval <<-METHOD
        def #{method}(*args)
          subclass_responsibility
        end
      METHOD
    end
  end
end
