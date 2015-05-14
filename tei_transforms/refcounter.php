<?php

/**
 * @file
 * Examine XML with wrapped text nodes for inclusion/exclusion.
 */

namespace VersionableObjectViewer;
use \DOMXPath, \DOMElement;

/**
 * Flag text nodes in the given document.
 *
 * Effectively goes over every (un/re)do node and flips the flag on the node
 * wrapping each text node. Kind of naive with respect to "redo", as we do not
 * first require something to be "undone" to apply it... Effectively, undo and
 * redo are handled the same.
 *
 * @param DOMDocument $doc
 *   The document in which to adjust the flags of wrapping nodes. Note: This
 *   document will be modified!
 */
function count_refs($doc) {
  $xpath = new DOMXPath($doc);
  $xpath->registerNamespace('wrap', 'http://islandora.ca/ontology/tei-text-wrapper');
  $xpath->registerNamespace('tei', 'http://www.tei-c.org/ns/1.0');

  foreach ($xpath->query('//tei:undo | //tei:redo') as $element) {
    deref_nodes($xpath, $element);
  }
}

/**
 * Actually flip the flags resulting from the given item.
 *
 * @param DOMXPath $xpath
 *   A DOMXPath instance, wrapping a document in which to flip things around.
 * @param DOMElement $element
 *   A DOMElement instance for which to flip flags. Should be either a tei:undo
 *   or a tei:redo.
 */
function deref_nodes(DOMXPath $xpath, DOMElement $element) {
  if ($element->hasAttribute('target')) {
    $targets = parse_target($element->getAttribute('target'));
    foreach ($targets as $target) {
      foreach ($xpath->query("//tei:*[(self::tei:undo or self::tei:redo) and '$target' = @xml:id and @xml:id]") as $wrapper) {
        // Find undo/redo elements which the current element targets, and apply
        // them.
        deref_nodes($xpath, $wrapper);
      }
      foreach ($xpath->query("//*[@xml:id and '$target' = @xml:id]//wrap:per") as $wrapper) {
        // For the nodes we specifically contain, flip the flag.
        $wrapper->setAttribute('refcount', $wrapper->getAttribute('refcount') * -1);
      }
    }
  }
  elseif ($element->hasAttribute('spanTo')) {
    $targets = parse_target($element->getAttribute('spanTo'));
    $target = reset($targets);
    foreach ($xpath->query("
      following::*[not(preceding::*[self::tei:anchor[@xml:id and '$target' = @xml:id]])]//wrap:per |
      following::wrap:per[not(preceding::*[self::tei:anchor[@xml:id and '$target' = @xml:id]])]", $element) as $wrapper) {
      // For each following wrapper text, including those further down the
      // hierarchy before the anchor, flip the flag.
      $wrapper->setAttribute('refcount', $wrapper->getAttribute('refcount') * -1);
    }
  }
}

/**
 * Helper function; parse "target" and "spanTo" values.
 *
 *
 * @param string $target
 *   A string containing the list of targets. They are understood to be a
 *   space-separated list of identifiers, each preceded by a hash (#) symbol.
 *
 * @return array
 *   An array of strings, each representing an identifier. Note: The leading
 *   hash has been stripped for convenience.
 */
function parse_target($target) {
  $targets = preg_split('/\s+/', $target);
  foreach ($targets as &$t) {
    // Naively strip the first character off (should be a "#").
    $t = substr($t, 1);
  }
  unset($t);
  return $targets;
}
