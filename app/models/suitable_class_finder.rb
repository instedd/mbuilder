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

class SuitableClassFinder

  attr_reader :collaborators, :classes

  DefaultIfFoundBlock = lambda do | class_found |
    class_found
  end

  DefaultIfMultipleBlock = lambda do |potential_classes, suitable_class_finder |
    raise "There should not be more than one class that could work with this objects." +
    " The classes #{potential_classes.inspect} can work with #{suitable_class_finder.collaborators.inspect}." +
    " This is a programming error."
  end

  DefaultIfNoneBlock = lambda do | suitable_class_finder |
    raise "None of the classes #{suitable_class_finder.classes.inspect} can work with #{suitable_class_finder.collaborators.inspect}." +
    " This is a programming error."
  end

  DefaultCanHandleMessage = :can_handle?

  def initialize a_collection_of_classes , params={}, &block
    @classes = a_collection_of_classes
    @testing_block = block
    @if_none_do_block = params[:if_none] || DefaultIfNoneBlock
    @if_multiple_do_block = params[:if_multiple] || DefaultIfMultipleBlock
    @if_found_do_block = params[:if_found] || DefaultIfFoundBlock
    @collaborators = Array(params[:suitable_for])
  end

  def self.find_direct_subclass_of an_abstract_class, params
    find_in an_abstract_class.subclasses, params
  end

  def self.find_leaf_subclass_of an_abstract_class, params={}, &block
    find_in an_abstract_class.all_leaf_subclasses, params, &block
  end

  def self.find_any_subclass_of an_abstract_class, params
    find_in an_abstract_class.all_subclasses, params
  end

  def self.find_in a_list_of_classes, params, &testing_block
    unless block_given?
      testing_message = params[:sending] || DefaultCanHandleMessage
      collaborators = Array(params[:suitable_for])
      testing_block = lambda do |a_class|
        a_class.send testing_message, *collaborators
      end
    end

    (self.new a_list_of_classes, params, &testing_block).value
  end

  def value
    suitable_classes = @classes.select &@testing_block

    if suitable_classes.size == 1
      @if_found_do_block.call suitable_classes.first
    else
      if suitable_classes.empty?
        @if_none_do_block.call self
      else
        @if_multiple_do_block.call suitable_classes, self
      end
    end
  end
end
