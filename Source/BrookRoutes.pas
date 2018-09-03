(*   _                     _
 *  | |__  _ __ ___   ___ | | __
 *  | '_ \| '__/ _ \ / _ \| |/ /
 *  | |_) | | | (_) | (_) |   <
 *  |_.__/|_|  \___/ \___/|_|\_\
 *
 *  –– an ideal Pascal microframework to develop cross-platform HTTP servers.
 *
 * Copyright (c) 2012-2018 Silvio Clecio <silvioprog@gmail.com>
 *
 * This file is part of Brook library.
 *
 * Brook framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Brook framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Brook framework.  If not, see <http://www.gnu.org/licenses/>.
 *)

unit BrookRoutes;

{$I Brook.inc}

interface

uses
  Classes,
  BrookHandledClasses;

type
  TBrookRoute = class(TBrookHandleCollectionItem)
  private
    FPattern: string;
  published
    property Pattern: string read FPattern write FPattern;
  end;

  TBrookRouteClass = class of TBrookRoute;

  TBrookRoutes = class(TBrookHandleOwnedCollection)
  public
    constructor Create(AOwner: TPersistent); virtual;
  end;

implementation

constructor TBrookRoutes.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TBrookRoute);
end;

end.
